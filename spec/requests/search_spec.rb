# frozen_string_literal: true

# spec/requests/search_spec.rb
require 'rails_helper'

RSpec.describe 'Search', type: :request do
  let(:author) { create(:author, given_name: 'Sam', family_name: 'Ruby') }
  let!(:book1) { create(:book, title: 'the ruby') }
  let!(:book2) { create(:book2, title: 'the awesome ruby') }
  let!(:book3) { create(:book3, title: 'another book', author: author) }

  describe 'GET /api/search/:text' do
    context 'with text = ruby' do
      before { get '/api/search/ruby' }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives a "ruby_microscope" document' do
        expect(json_body['data'][0]['searchable_id']).to eq book1.id
        expect(json_body['data'][0]['searchable_type']).to eq 'Book'
      end

      it 'receives a "rails_tutorial" document' do
        expect(json_body['data'][1]['searchable_id']).to eq book2.id
        expect(json_body['data'][1]['searchable_type']).to eq 'Book'
      end

      it 'receives a "sam ruby" document' do
        expect(json_body['data'][2]['searchable_id']).to eq book3.author.id
        expect(json_body['data'][2]['searchable_type']).to eq 'Author'
      end
    end
  end
end
