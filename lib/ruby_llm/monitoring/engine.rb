require "importmap-rails"
require "stimulus-rails"
require "turbo-rails"

module RubyLLM
  module Monitoring
    class Engine < ::Rails::Engine
      isolate_namespace RubyLLM::Monitoring

      INFLECTION_OVERRIDES = { "ruby_llm" => "RubyLLM" }.freeze

      initializer "ruby_llm_monitoring.inflector", after: "ruby_llm.inflections", before: :set_autoload_paths do
        ActiveSupport::Inflector.inflections(:en) do |inflections|
          # The RubyLLM gem registers "RubyLLM" as an acronym in its railtie,
          # which breaks underscore conversion (RubyLLM.underscore => "rubyllm").
          # We need to remove it and use "LLM" as an acronym instead for proper conversion:
          # * "ruby_llm".camelize => "RubyLLM" (not "RubyLlm")
          # * "RubyLLM".underscore => "ruby_llm" (not "rubyllm")
          inflections.acronyms.delete("rubyllm")
          inflections.acronym("LLM")
        end

        Rails.autoloaders.each do |loader|
          loader.inflector.inflect(INFLECTION_OVERRIDES)
        end
      end

      initializer "ruby_llm_monitoring.assets" do |app|
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/assets/images")
        app.config.assets.paths << root.join("app/javascript")

        app.config.assets.precompile += %w[
          ruby_llm/monitoring/application.css
          ruby_llm/monitoring/bulma.min.css
          ruby_llm/monitoring/application.js
          ruby_llm/monitoring/controllers/application.js
          ruby_llm/monitoring/controllers/index.js
        ]
      end

      initializer "ruby_llm_monitoring.importmap", after: "importmap" do |app|
        RubyLLM::Monitoring.importmap.draw(root.join("config/importmap.rb"))
        RubyLLM::Monitoring.importmap.cache_sweeper(watches: root.join("app/javascript"))

        ActiveSupport.on_load(:action_controller_base) do
          before_action { RubyLLM::Monitoring.importmap.cache_sweeper.execute_if_updated }
        end
      end

      initializer "ruby_llm_monitoring.event_subscribe" do
        ActiveSupport::Notifications.subscribe /ruby_llm/, EventSubscriber.new
      end

      initializer "ruby_llm_monitoring.register_builtin_channels" do
        RubyLLM::Monitoring.channel_registry.register :slack, Channels::Slack
        RubyLLM::Monitoring.channel_registry.register :email, Channels::Email
      end
    end
  end
end
