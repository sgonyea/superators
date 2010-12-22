module Superators
  BINARY_RUBY_OPERS = %w[** * / % + - << >> & | ^ <=> >= <= < > === == =~]
  UNARY_RUBY_OPERS  = %w[-@ ~@ +@]

  BINARY_OPER_PATTERN   = BINARY_RUBY_OPERS.map {|x| Regexp.escape(x) }.join "|"
  UNARY_OPER_PATTERN    = UNARY_RUBY_OPERS.map  {|x| Regexp.escape(x) }.join "|"
  UNARY_OPS_SANS_ATSYM  = UNARY_OPER_PATTERN.gsub '@', ''

  VALID_SUPERATOR = %r[^(#{BINARY_OPER_PATTERN})(#{UNARY_OPS_SANS_ATSYM})+$]

  def _send(sup, operand)
    raise NoMethodError, "Superator #{sup} has not been defined on #{self.class}" unless superates?(sup)

    __send__(name_for(sup), operand)
  end

  def superates?(sup)
    respond_to?(name_for sup)
  end

  def superators
    methods.grep(/^superator_definition_/).map {|m| decode m}
  end

protected
  def superator(operator, &block)
    raise ArgumentError, "block not supplied"     unless block_given?
    raise ArgumentError, "Not a valid superator!" unless valid?(operator)

    binary_operator = grep_binary_operator(operator)

    class_eval do
      # Step in front of the old operator's dispatching.
      real_method_alias = alias_superator(binary_operator, operator)

      define_method(name_for(operator), &block)

      # When we get to the method defining, we have to know whether the superator had to be aliased or if it's new entirely.
      define_method(binary_operator) do |operand|
        if operand.kind_of?(SuperatorFlag) && operand.has_stack?
          sup = operand.unshift_stack(binary_operator).join

          operand.clear_stack

          _send(sup, operand)
        else
          # If the method_alias is defined
          if respond_to?(real_method_alias)
            __send__(real_method_alias, operand)
          else
            raise NoMethodError, "undefined method #{binary_operator} for #{operand.inspect}:#{operand.class}"
          end
        end
      end
    end # class_eval

    def undef_superator(sup)
      if superates?(sup)
        binary_operator       = grep_binary_operator(sup)
        binary_operator_alias = alias_for(sup)

        class << self; self; end.instance_eval do
          undef_method(name_for sup)
          if respond_to?(binary_operator_alias)
            alias_method(binary_operator, binary_operator_alias) if superators.empty?
          else
            undef_method(binary_operator)
          end
        end
      else
        raise NoMethodError, "undefined superator #{sup} for #{self.inspect}:#{self.class}"
      end
    end
  end # def superator

private
  def alias_superator(binary_operator, super_operator)
    real_method_alias = alias_for(binary_operator)

    if instance_methods.include?(binary_operator) && !superates?(super_operator)
      alias_method(real_method_alias, binary_operator)
    end

    return real_method_alias
  end

  def encode(str)
    tokenizer = /#{BINARY_OPER_PATTERN}|#{UNARY_OPS_SANS_ATSYM}/

    str.scan(tokenizer).map {|op|
      op.each_char.map {|s| s[0]}.join("_")
    }.join("__")
  end

  def decode(str)
    tokens = str.match /^(superator_(definition|alias_for))?((_?\d{2,3})+)((__\d{2,3})+)$/
    #puts *tokens
    if tokens
      (tokens[3].split("_") + tokens[5].split('__')).reject(&:empty?).map{|s| s.to_i.chr}.join
    end
  end

  def grep_binary_operator(sup)
    sup[/^#{BINARY_OPER_PATTERN}/]
  end

  def alias_for(name)
    "alias_for_#{encode(name)}"
  end

  def name_for(sup)
    "superator_definition_#{encode(sup)}"
  end

  def valid?(operator)
    operator =~ VALID_SUPERATOR
  end
end

module SuperatorFlag
end
