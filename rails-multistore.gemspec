# frozen_string_literal: true

require_relative "lib/rails_multistore/version"

Gem::Specification.new do |spec|
  spec.name        = "rails-multistore"
  spec.version     = RailsMultistore::VERSION
  spec.authors     = ["Eric Laquer"]
  spec.email       = ["laquereric@gmail.com"]
  spec.homepage    = "https://github.com/laquereric/rails-multistore"
  spec.summary     = "Unified interface for managing multiple data stores in Rails"
  spec.description = "Rails Multistore provides a unified interface for pushing data to and querying from multiple data stores simultaneously. Each store type is implemented as a separate Rails engine."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "{app,lib}/**/*",
    "MIT-LICENSE",
    "Rakefile",
    "README.md"
  ]

  spec.required_ruby_version = ">= 3.3.6"

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "activejob", ">= 7.0"

  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "cucumber-rails", "~> 3.0"
  spec.add_development_dependency "database_cleaner", "~> 2.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
end
