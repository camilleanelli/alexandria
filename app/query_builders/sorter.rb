# frozen_string_literal: true

class Sorter
  DIRECTIONS = %w[asc desc].freeze

  def initialize(scope, params)
    @scope = scope
    @presenter = "#{@scope.model}Presenter".constantize
    @column = params[:sort]
    @direction = params[:dir]
  end

  def sort
    return @scope unless @column && @direction

    # on raise des erreurs si les parametres sort ou dir sont invalides
    error!('sort', @column) unless @presenter.sort_attributes.include?(@column)
    error!('dir', @direction) unless DIRECTIONS.include?(@direction)

    @scope.order("#{@column} #{@direction}")
  end

  private

  def error!(name, value)
    columns = @presenter.sort_attributes.join(',')
    raise QueryBuilderError.new("#{name}=#{value}"),
          "Invalid sorting params. sort: (#{columns}), 'dir': asc, desc"
  end
end
