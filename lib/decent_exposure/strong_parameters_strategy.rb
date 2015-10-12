require 'decent_exposure/active_record_strategy'

module DecentExposure
  class StrongParametersStrategy < ActiveRecordStrategy
    def attributes
      return @attributes if defined?(@attributes)
      @attributes = controller.send(options[:attributes]) if options[:attributes]
    end

    def assign_attributes?
      singular? && (post? || put? || patch?) && attributes.present?
    end

    def resource
      super.tap do |r|
        r.attributes = attributes if assign_attributes?
      end
    end
  end
end
