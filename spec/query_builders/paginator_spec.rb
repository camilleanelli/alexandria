# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Paginator do
  let(:book1) { create(:book) }
  let(:book2) { create(:book2) }
  let(:book3) { create(:book3) }
  let(:books) { [book1, book2, book3] }

  let(:scope) do
    Book.all
  end

  let(:params) do
    { 'page' => '1', 'per' => '2' }
  end

  let(:paginator) { Paginator.new(scope, params, 'url') }
  let(:paginated) { paginator.paginate }

  before do
    books
  end

  describe '#paginate' do
    it 'paginate the collection with 2 books' do
      expect(paginated.size).to eq(2)
    end

    it 'contains book1 as first paginated item' do
      expect(paginated.first).to eq book1
    end

    it 'contains book2 as the last paginated item' do
      expect(paginated.last).to eq(book2)
    end
  end

  describe '#links' do
    let(:links) { paginator.links.split(', ') }

    context 'when first page' do
      let(:params) { { 'page' => '1', 'per' => '2' } }

      it 'builds the next relation link' do
        expect(links.first).to eq '<url?page=2&per=2>; rel="next"'
      end

      it 'builds the last relation link' do
        expect(links.last).to eq '<url?page=2&per=2>; rel="last"'
      end
    end

    context 'when last page' do
      let(:params) { { 'page' => '2', 'per' => '2' } }

      it 'builds the first relation link' do
        puts paginator.inspect
        expect(links.first).to eq '<url?page=1&per=2>; rel="first"'
      end

      it 'builds the previous relation link' do
        expect(links.last).to eq '<url?page=1&per=2>; rel="prev"'
      end
    end
  end
end
