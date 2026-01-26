require_relative "lib/ruby_llm/monitoring/version"

Gem::Specification.new do |spec|
  spec.name        = "ruby_llm-monitoring"
  spec.version     = RubyLLM::Monitoring::VERSION
  spec.authors     = [ "Patricio Mac Adden" ]
  spec.email       = [ "patricio.macadden@sinaptia.dev" ]
  spec.homepage    = "https://github.com/sinaptia/ruby_llm-monitoring"
  spec.summary     = "Monitoring engine for RubyLLM"
  spec.description = "Monitoring engine for RubyLLM"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "groupdate"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "rails", ">= 7.2.0"
  spec.add_dependency "ruby_llm"
  spec.add_dependency "ruby_llm-instrumentation", ">= 0.1"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "turbo-rails"
end
