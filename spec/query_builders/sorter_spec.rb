# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sorter do
  let(:book1) { create(:book, title: 'title_book1') }
  let(:book2) { create(:book2, title: 'title_book2') }
  let(:book3) { create(:book3, title: 'title_book3') }
  let(:books) { [book1, book2, book3] }
  let(:scope) { Book.all }

  let(:params) { HashWithIndifferentAccess.new(sort: 'id', dir: 'desc') }
  let(:sorter) { Sorter.new(scope, params) }
  let(:sorted) { sorter.sort }

  before do
    allow(BookPresenter).to receive(:sort_attributes).and_return(%w[id title])
    books
  end

  describe '#sort' do
    context 'without any parameters' do
      let(:params) { {} }
      it 'returns the scope unchanged' do
        expect(sorted).to eq scope
      end
    end

    context 'with valid parameters' do
      it 'sorts the collection by id desc' do
        expect(sorted.first.id).to eq book3.id
        expect(sorted.last.id).to eq book1.id
      end

      it 'sorts the collection by title asc' do
        params = HashWithIndifferentAccess.new(sort: 'title', dir: 'asc')
        sorter = Sorter.new(scope, params)
        sorted = sorter.sort

        expect(sorted.first).to eq book1
        expect(sorted.last).to eq book3
      end
    end

    context 'with invalid parameters' do
      let(:params) { HashWithIndifferentAccess.new(sort: 'fid', dir: 'desc') }
      it 'raises a QueryBuilderError exception' do
        # on passe bien un block pour vérifier le raise
        expect { sorted }.to raise_error(QueryBuilderError)
      end
    end
  end
end
