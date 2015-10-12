require 'decent_exposure/strategizer'
require 'decent_exposure/configuration'

module DecentExposure
  module Controller
    def self.included(base)
      base.class_eval do
        class_attribute :decent_configurations
        self.decent_configurations ||= Hash.new(Configuration.new)

        def resources
          @resources ||= {}
        end
        hide_action :resources

        protected_instance_variables << "@_resources"

        extend ClassMethods
      end
    end

    module ClassMethods
      def exposures
        @exposures ||= {}
      end

      def decent_configuration(name = :default, &block)
        self.decent_configurations = decent_configurations.merge(name => Configuration.new(&block))
      end

      def expose!(*args, &block)
        set_callback(:process_action, :before, args.first)
        expose(*args, &block)
      end

      def warning
        Kernel.warn <<-EOS
          [WARNING] You are exposing the `#{name}` method,
          which overrides an existing ActionController method of the same name.
          Consider a different exposure name
          #{caller.first}
        EOS
      end

      def method_already_exists_in_rails?(name)
        ActionController::Base.instance_methods.include?(name.to_sym)
      end

      def expose(name, options={}, &block)
        if method_already_exists_in_rails?(name) then warning end

        config = options[:config] || :default
        options = decent_configurations[config].merge(options)

        exposures[name] = exposure = Strategizer.new(name, options, &block).strategy

        define_exposure_methods(name, exposure)
      end

      private

      def define_exposure_methods(name, exposure)
        define_method(name) do
          return resources[name] if resources.has_key?(name)
          resources[name] = exposure.call(self)
        end
        helper_method name
        hide_action name

        define_method("#{name}=") do |value|
          resources[name] = value
        end
        hide_action "#{name}="
      end
    end
  end
end
