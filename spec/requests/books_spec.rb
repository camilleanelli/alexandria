# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let!(:book1) { create(:book) }
  let!(:book2) { create(:book2) }
  let!(:book3) { create(:book3) }

  let(:books) { [book1, book2, book3] }

  # describe 'GET /api/books' do
  #   before { get '/api/books' }

  #   it 'receives http status 200' do
  #     expect(response.status).to eq 200
  #   end

  #   it 'receive a json response with data' do
  #     expect(json_body['data']).to_not be_nil
  #   end

  #   it 'receives 3 items in the data' do
  #     expect(json_body['data'].size).to eq 3
  #   end
  # end

  describe 'field picking' do
    context 'with the fields parameter' do
      before { get '/api/books?fields=id,title,author_id' }

      it 'gets books with only the id,title, and author_id keys' do
        json_body['data'].each do |book|
          expect(book.keys).to eq %w[id title author_id]
        end
      end
    end

    context 'without the fields params' do
      before { get '/api/books/' }

      it 'get all the attributes of the book presenter' do
        json_body['data'].each do |book|
          expect(book.keys).to eq BookPresenter.build_attributes.map(&:to_s)
        end
      end
    end
  end
end
