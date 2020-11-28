# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FieldPicker' do
  # We define 'let' in cascade where each one of them is used by the # one below. This allows us to override any of them easily in a
  # specific context.
  let(:rails_tutorial) { create(:book) }
  let(:params) { { fields: 'id,title,subtitle' } }
  let(:presenter) { BookPresenter.new(rails_tutorial, params) }
  let(:field_picker) { FieldPicker.new(presenter) }
  # We don't want our tests to rely too much on the actual implementation of # the book presenter. Instead, we stub the method 'build_attributes'
  # on BookPresenter to always return the same list of attributes for
  # the tests in this file
  before do
    allow(BookPresenter).to(receive(:build_attributes).and_return(%w[id title author_id]))
  end

  describe '#pick' do
    context 'with the "fields" parameter containing "id,title,subtitle"' do
      it 'updates the presenter "data" with the book "id" and "title"' do
        expect(field_picker.pick.data).to eq('id' => rails_tutorial.id, 'title' => 'Le portrait de Doriane Grey')
      end
    end

    context 'with no "fields" parameter' do
      let(:empty_params) do
        { fields: '' }
      end
      let(:presenter2) { BookPresenter.new(rails_tutorial, empty_params) }
      let(:field_picker2) { FieldPicker.new(presenter2) }
      # I mentioned earlier how we can easily override any 'let'.
      # Here we just override the 'params' let which will be used in place # of the one we created earlier, but only in this context let(:params) { {} }
      it 'updates "data" with the fields ("id","title","author_id")' do
        expect(field_picker2.send(:pick).data).to eq(
          'id' => rails_tutorial.id,
          'title' => 'Le portrait de Doriane Grey',
          'author_id' => 1
        )
      end
    end
  end
end
