# frozen_string_literal: true

class BasePresenter
  # c'est la classe parente des presenters de chaque ressources
  # pour définir des méthodes qui permettent d'autoriser les attributs
  # Define a class level instance variable
  @build_attributes = []
  @relations = []
  @sort_attributes = []
  @filter_attributes = []
  # Open the door to class methods
  class << self
    # Define an accessor for the class level instance # variable we created above
    attr_accessor :build_attributes, :relations, :sort_attributes, :filter_attributes
    # Create the actual class method that will
    # be used in the subclasses
    # We use the splash operation '*' to get all # the arguments passed in an array
    def build_with(*args)
      @build_attributes = args.map(&:to_s)
    end

    def related_to(*args)
      @relations = args.map(&:to_s)
    end

    def sort_by(*args)
      @sort_attributes = args.map(&:to_s)
    end

    def filter_by(*args)
      @filter_attributes = args.map(&:to_s)
    end
  end

  attr_accessor :object, :data, :params

  def initialize(object, params, options = {})
    @object = object
    @params = params
    @options = options
    @data = HashWithIndifferentAccess.new
  end

  def as_json(*)
    @data
  end
end
