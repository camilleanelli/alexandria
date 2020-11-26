# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let!(:book1) { create(:book) }
  let!(:book2) { create(:book2) }
  let!(:book3) { create(:book3) }

  let(:books) { [book1, book2, book3] }

  describe 'GET /api/books' do
    before { get '/api/books' }

    it 'receives http status 200' do
      expect(response.status).to eq 200
    end

    it 'receive a json response with data' do
      expect(json_body['data']).to_not be_nil
    end

    it 'receives 3 items in the data' do
      expect(json_body['data'].size).to eq 3
    end
  end
end
