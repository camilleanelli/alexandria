# frozen_string_literal: true

class RepresentationBuilderError < StandardError
  attr_accessor :invalid_params

  def initialize(invalid_params)
    @invalid_params = invalid_params
  end
end
