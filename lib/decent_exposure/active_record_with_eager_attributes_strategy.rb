require 'decent_exposure/active_record_strategy'

module DecentExposure
  class ActiveRecordWithEagerAttributesStrategy < ActiveRecordStrategy
    def attributes
      params[options[:param_key] || inflector.param_key] || {}
    end

    def assign_attributes?
      return false unless attributes && singular?
      post? || put? || patch? || new_record?
    end

    def new_record?
      !id
    end

    def resource
      r = super
      r.attributes = attributes if assign_attributes?
      r
    end
  end
end
