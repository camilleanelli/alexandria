# frozen_string_literal: true

class FieldPicker
  def initialize(presenter)
    @presenter = presenter
    @fields ||= validate_fields
  end

  def pick
    # on rempli la data du presenter avec build_fields
    build_fields
    @presenter
  end

  private

  def build_fields
    # on nourrit la méthode data du presenter avec les valeurs des champs appelés sur l'objet
    @fields.each do |field|
      target = @presenter.respond_to?(field) ? @presenter : @presenter.object
      @presenter.data[field] = target.send(field) if target
    end
  end

  def validate_fields
    return pickable if @presenter.params[:fields].blank?

    fields = @presenter.params[:fields].present? ?
    @presenter.params[:fields].split(',') : []

    return pickable if fields.blank?

    # fields = @presenter.params[:fields].split(',')
    fields.each do |field|
      error!(field) unless pickable.include?(field)
    end
    fields
  end

  def error!(field)
    build_attributes = @presenter.class.build_attributes.join(',')
    raise RepresentationBuilderError.new("fields=#{field}"),
          "Invalide field pick. Allowed field: (#{build_attributes})"
  end

  def pickable
    # tous les attributs acceptables ou permitted_attributes
    @pickable ||= @presenter.class.build_attributes
  end
end
