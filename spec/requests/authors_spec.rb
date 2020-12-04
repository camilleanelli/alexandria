# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authors', type: :request do
  let!(:author1) { create(:oscar, given_name: 'Oscar', family_name: 'Wild') }
  let!(:author2) { create(:oscar, given_name: 'Victor', family_name: 'Hugos') }
  let!(:author3) { create(:oscar, given_name: 'Margaret', family_name: 'Atwood') }

  describe 'GET /api/authors' do
    context 'default behavior' do
      it 'renders all the authors' do
        get '/api/authors'
        expect(response.status).to eq 200
      end
    end

    describe 'field picking' do
      context 'With the fields parameter' do
        it 'renders the fields picking only' do
          get '/api/authors?fields=family_name'
          expect(json_body['data'].map(&:keys)).to_not include 'given_name'
        end
      end

      context 'without the field parameter' do
        it 'renders all the fields allowed for an author' do
          get '/api/authors'
          expect(json_body['data'].first.keys).to eq %w[id given_name family_name created_at updated_at]
        end
      end

      context 'with invalid field name fid' do
        it 'renders error message' do
          get '/api/authors?fields=fid'
          expect(response.status).to eq 400
          expect(json_body['error']).to_not be nil
        end
      end
    end

    describe 'pagination' do
      context 'when asking for the first page' do
        it 'render the first 2 authors' do
          get '/api/authors?page=1&per=2'
          expect(json_body['data'].size).to eq 2
          expect(json_body['data'].last['id']).to eq author2.id
        end
      end

      context 'when asking for the second page' do
        it 'render the 3rd auhor' do
          get '/api/authors?page=2&per=2'
          expect(json_body['data'].size).to eq 1
          expect(json_body['data'].last['id']).to eq author3.id
        end
      end

      context 'when sending invalid "page" and "per" parameters' do
        it 'renders an error 400' do
          get '/api/authors?page=toto&per=toto'
          expect(response.status).to eq 400
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        it 'renders the authors by ids' do
          get '/api/authors?sort=id&dir=desc'
          expect(json_body['data'].first['id']).to eq author3.id
        end
      end

      context 'with invalid column name "fid"' do
        it 'renders a 400 http status' do
          get '/api/authors?sort=fid&dir=fid'
          expect(response.status).to eq 400
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[given_name_cont]=Osc"' do
        it 'render the author corresponding' do
          get '/api/authors?q[given_name_cont]=Osc'
          expect(response.status).to eq 200
          expect(json_body['data'].first['given_name']).to eq 'Oscar'
        end
      end

      context 'with invalid filtering param "q[fgiven_name_cont]=Osc"' do
        it 'renders status error 400' do
          get '/api/authors?q[fgiven_name_cont]=Osc'
          expect(response.status).to eq 400
        end
      end
    end
  end

  describe 'GET /api/authors/:id' do
    context 'with existing resource' do
      it 'renders the existing resource' do
        get "/api/authors/#{author1.id}"
        expect(response.status).to eq 200
        expect(json_body['data']['id']).to eq author1.id
      end
    end

    context 'with nonexistent resource' do
      it 'renders status 404 not found' do
        get '/api/authors/12234'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/authors' do
    context 'with valid parameters' do
      let(:params) { { data: { given_name: 'Stephen', family_name: 'King' } } }
      it 'create a new author' do
        expect { post '/api/authors', params: params }.to change { Author.count }.by(1)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { data: { toto: 'Stephen' } } }
      it 'do not create any authors' do
        expect { post '/api/authors', params: params }.to change { Author.count }.by(0)
      end

      it 'renders a status error 422' do
        post '/api/authors', params: params
        expect(response.status).to eq 422
      end
    end
  end

  describe 'PATCH /api/authors/:id' do
    context 'with valid parameters' do
      let(:params) do
        { data: {
          given_name: 'Other name'
        } }
      end
      it 'updates the author' do
        patch "/api/authors/#{author1.id}", params: params
        expect(json_body['data']['given_name']).to eq 'Other name'
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        { data: {
          given_name: ''
        } }
      end

      it 'do not update any author' do
        patch "/api/authors/#{author1.id}", params: params
        expect(author1.given_name).to eq 'Oscar'
        expect(response.status).to eq 422
      end
    end
  end

  describe 'DELETE /api/authors/:id' do
    context 'with existing resource' do
      it 'delete the author' do
        delete "/api/authors/#{author1.id}"
        expect(Author.count).to eq 2
      end
    end

    context 'with nonexistent resource' do
      it 'renders an error 404' do
        delete '/api/authors/1234'
        expect(response.status).to eq 404
      end
    end
  end
end
