$:.push File.expand_path("../lib", __FILE__)
require "superators/version"

Gem::Specification.new do |s|
  s.name        = "superators"
  s.version     = Superators::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jay Phillips"]
  s.email       = ["jay@codemecca.com"]
  s.homepage    = "http://jicksta.com"
  s.summary     = %q{Superators add new sexy operators to your Ruby objects.}
  s.description = %q{Superators are a superset of new Ruby operators you can create and use.}

  s.add_development_dependency "rspec"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
