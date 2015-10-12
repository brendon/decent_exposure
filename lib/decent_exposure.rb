require 'active_support/all'
require 'decent_exposure/controller'
require 'decent_exposure/error'

ActiveSupport.on_load(:action_controller) do
  include DecentExposure::Controller
end
