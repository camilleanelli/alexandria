# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Filter do
  let!(:book1) { create(:book, title: 'title_1', released_on: '2012-05-10') }
  let!(:book2) { create(:book2, title: 'title_2') }
  let!(:book3) { create(:book3, title: 'title_3') }

  let(:scope) { Book.all }
  let(:params) { {} }
  let(:filter) { Filter.new(scope, params) }
  let(:filtered) { filter.filter }

  before do
    allow(BookPresenter).to receive(:filter_attributes).and_return(%w[id title released_on])
  end

  describe '#filter' do
    context 'without any parameters' do
      it 'returns the scope unchanged' do
        expect(filtered).to eq scope
      end
    end

    context 'with valid parameters' do
      context 'with title_eq=title_1' do
        let(:params) { { 'q' => { 'title_eq' => 'title_1' } } }

        it 'gets only title_1 ' do
          expect(filtered.first.id).to eq book1.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with title_cont=under' do
        let(:params) { { 'q' => { 'title_cont' => '1' } } }

        it 'gets only title_1' do
          expect(filtered.first.id).to eq book1.id
          expect(filtered.size).to eq 1
        end
      end

      context 'with title_notcont=1' do
        let(:params) { { 'q' => { 'title_notcont' => '1' } } }
        it 'gets only title_2 and title_3' do
          expect(filtered).to include(book2)
          expect(filtered.size).to eq 2
        end
      end

      context 'with "title_start=Ruby"' do
        let(:params) { { 'q' => { 'title_start' => 'title' } } }
        it 'gets all books starting with title' do
          expect(filtered.size).to eq 3
        end
      end

      context 'with "title_end=Tutorial"' do
        let(:params) { { 'q' => { 'title_end' => '2' } } }
        it 'gets only title_2' do
          expect(filtered.first).to eq book2
        end
      end

      context 'with "released_on_lt=2013-05-10"' do
        let(:params) { { 'q' => { 'released_on_lt' => '2013-05-10' } } }
        it 'gets only the book with released_on before 2013-05-10' do
          expect(filtered.first.title).to eq 'title_1'
          expect(filtered.size).to eq 1
        end
      end

      context 'with "released_on_gt=2014-01-01"' do
        let(:params) { { 'q' => { 'released_on_gt' => '2014-01-01' } } }
        it 'gets only the book with id 1' do
          expect(filtered.first.title).to eq 'title_2'
          expect(filtered.size).to eq 2
        end
      end
    end

    context 'with invalid parameters' do
      context 'with invalid column name "fid"' do
        let(:params) { { 'q' => { 'fid_gt' => '2' } } }
        it 'raises a "QueryBuilderError" exception' do
          expect { filtered }.to raise_error(QueryBuilderError)
        end
      end

      context 'with invalid predicate "gtz"' do
        let(:params) { { 'q' => { 'id_gtz' => '2' } } }
        it 'raises a "QueryBuilderError" exception' do
          expect { filtered }.to raise_error(QueryBuilderError)
        end
      end
    end
  end
end
