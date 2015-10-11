require 'active_support/all'
require 'action_controller'
require 'action_dispatch'
require 'active_model'
require 'active_record'
require 'rails'
require 'spec_helper'

# Boilerplate
module Rails
  class App
    def env_config; {} end
    def routes
      return @routes if defined?(@routes)
      @routes = ActionDispatch::Routing::RouteSet.new
      @routes.tap do |routes|
        routes.draw do
          get '/bird/new'              => "bird#new"
          get '/birds'                 => "bird#index"
          get '/bird/(:id)'            => "bird#show"
          get '/duck/(:id)'            => "duck#show"
          get '/mallard/(:id)'         => "mallard#show"
          get '/taxonomies/(:id)'      => "taxonomies#show"
          get '/namespace/model/:id'   => "namespace/model#show"
          get '/strong_parameters/:id' => "strong_parameters#show"
        end
      end
    end
  end
  def self.application
    @app ||= App.new
  end
end

# Models
class Parrot
  attr_accessor :beak
  extend ActiveModel::Naming
  def initialize(attrs={})
    self.attributes = attrs
  end
  def self.find(id)
    new if id
  end
  def attributes=(attributes)
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

module Admin
  class Parrot < ::Parrot
    def beak
      @beak ||= "admin"
    end
  end
end

class Albatross
  extend ActiveModel::Naming
  def self.scoped
    [new, new]
  end

  def self.all
    scoped
  end
end

class Organism
  extend ActiveModel::Naming
  attr_accessor :species

  def initialize(attrs={})
    self.attributes = attrs
  end

  def self.find_by_itis_id(itis_id)
    new
  end

  def self.scoped
    [new, new]
  end

  def self.all
    scoped
  end

  def self.find(id)
    new(:species => 'Striginae')
  end

  def attributes=(attributes)
    attributes.each { |k,v| send("#{k}=", v) }
  end
end

Duck = Struct.new(:id)

class DuckCollection
  def ducks
    @ducks ||= [Duck.new("quack"), Duck.new("burp")]
  end

  def find(id)
    ducks.detect { |d| d.id == id }
  end
end

class CustomStrategy < DecentExposure::Strategy
  def resource
    name + controller.params[:action]
  end
end

# Controllers
class BirdController < ActionController::Base
  include Rails.application.routes.url_helpers
  expose(:bird) { "Bird" }
  expose(:ostrich) { "Ostrich" }
  expose(:albatrosses)
  expose(:parrot)
  expose(:organisms, :model => Organism)

  expose(:custom, :strategy => CustomStrategy)

  expose(:albert, :model => :parrot)
  expose(:bernard, :model => Admin::Parrot)

  decent_configuration(:custom) do
    strategy CustomStrategy
  end

  expose(:custom_from_config, :config => :custom)

  def show
    render :text => "Foo"
  end

  def index
    self.bird = Parrot.new(:beak => "custom")
    render :text => "index"
  end

  def new
    render :text => "new"
  end
end

class DuckController < BirdController
  expose(:bird) { "Duck" }
  expose(:ducks) { DuckCollection.new }
  expose(:duck)

  expose(:custom_from_config, :config => :custom)
end

class MallardController < DuckController; end

class StrongParametersController < ActionController::Base
  include Rails.application.routes.url_helpers

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  expose(:assignable, :attributes => :assignable_attributes, :model => Parrot)
  expose(:unassignable, :model => Parrot)

  def show
    render :text => "show"
  end

  def assignable_attributes
    params[:assignable]
  end
end

class ::Model
  def self.find(*); new end
  def name; "outer" end
end

module ::Namespace
  class Model
    def self.find(*); new end
    def name; "inner" end
  end

  class ModelController < ActionController::Base
    include Rails.application.routes.url_helpers
    expose(:model)
    def show; render :text => ""; end
  end
end

class TaxonomiesController < ActionController::Base
  include Rails.application.routes.url_helpers

  decent_configuration do
    finder :find_by_itis_id
  end

  decent_configuration(:owl_find) do
    finder :find
  end

  expose(:organism)
  expose(:owl, :config => :owl_find, :model => :organism)

  def show
    render :text => 'show'
  end
end
