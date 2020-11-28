# frozen_string_literal: true

class FieldPicker
  def initialize(presenter)
    @presenter = presenter
    @fields = @presenter.params[:fields]
  end

  def pick
    (validate_fields || pickable).each do |field|
      value = (@presenter.respond_to?(field) ? @presenter : @presenter.object).send(field)
      @presenter.data[field] = value
    end
    @presenter
  end

  private

  def validate_fields
    return nil if @fields.blank?

    # on vérifie si les champs demandés font parti des attributs acceptables
    validated = @fields.split(',').select { |f| pickable.include?(f) }
    validated.any? ? validated : nil
  end

  def pickable
    # tous les attributs acceptables
    @pickable ||= @presenter.class.build_attributes
  end
end
