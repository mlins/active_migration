# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_migration}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Lins"]
  s.date = %q{2008-11-22}
  s.description = %q{A library to assist with the migration of data from legacy databases.}
  s.email = %q{mattlins@gmail.com}
  s.files = ["CHANGELOG", "MIT-LICENSE", "Rakefile", "README", "VERSION.yml", "lib/active_migration", "lib/active_migration/base.rb", "lib/active_migration/callbacks.rb", "lib/active_migration/dependencies.rb", "lib/active_migration/key_mapper.rb", "lib/active_migration/version.rb", "lib/active_migration.rb", "lib/activemigration.rb", "spec/base_spec.rb", "spec/callbacks_spec.rb", "spec/dependencies_spec.rb", "spec/fixtures", "spec/fixtures/product_eight_migration.rb", "spec/fixtures/product_five_migration.rb", "spec/fixtures/product_four_migration.rb", "spec/fixtures/product_nine_migration.rb", "spec/fixtures/product_one_migration.rb", "spec/fixtures/product_seven_migration.rb", "spec/fixtures/product_six_migration.rb", "spec/fixtures/product_ten_migration.rb", "spec/fixtures/product_three_migration.rb", "spec/fixtures/product_two_migration.rb", "spec/key_mapper_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
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
