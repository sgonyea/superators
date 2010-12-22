class Object
  def -@
    extend SuperatorFlag
    unshift_stack '-'
    self
  end

  def +@
    extend SuperatorFlag
    unshift_stack '+'
    self
  end

  def ~@
    extend SuperatorFlag
    unshift_stack '~'
    self
  end

  def superator_stack
    @superator_stack ||= []
  end

  def unshift_stack(_op)
    superator_stack.unshift _op
  end

  def shift_stack
    superator_stack.shift
  end

  def clear_stack
    superator_stack.clear
  end

  def has_stack?
    superator_stack.any?
  end
end
