# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_migration}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Lins"]
  s.date = %q{2008-11-22}
  s.description = %q{A library to assist with the migration of data from legacy databases.}
  s.email = %q{mattlins@gmail.com}
  s.homepage = %q{http://github.com/mlins/active_migration}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library to assist with the migration of data from legacy databases.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.2.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_dependency(%q<activerecord>, [">= 2.2.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    s.add_dependency(%q<activerecord>, [">= 2.2.2"])
  end
end
