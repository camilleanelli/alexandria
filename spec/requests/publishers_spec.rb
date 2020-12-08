# frozen_string_literal: true

# spec/requests/publishers_spec.rb
require 'rails_helper'
RSpec.describe 'Publishers', type: :request do
  before do
    allow_any_instance_of(PublishersController).to(
      receive(:validate_auth_scheme).and_return(true)
    )
    allow_any_instance_of(PublishersController).to(
      receive(:authenticate_client).and_return(true)
    )
  end
  let!(:publisher1) { create(:publisher, name: 'the publisher') }
  let!(:publisher2) { create(:publisher, name: 'pragmatic studio') }
  let!(:publisher3) { create(:publisher, name: 'super book') }

  describe 'GET /api/publishers' do
    context 'default behavior' do
      it 'renders all the publishers' do
        get '/api/publishers'
        expect(json_body['data'].size).to eq 3
        expect(response.status).to eq 200
      end
    end

    describe 'field picking' do
      context 'with the fields parameter' do
        it 'renders publishers with only fields from parameters' do
          get '/api/publishers?fields=id'
          expect(json_body['data'].first.keys).to_not include 'name'
        end
      end
      context 'without the field parameter' do
        it 'renders all fields from publishers' do
          get '/api/publishers'
          expect(json_body['data'].first.keys).to contain_exactly('id', 'name', 'created_at', 'updated_at')
        end
      end
      context 'with invalid field name "fid"' do
        it 'renders error status' do
          get '/api/publishers?fields=fid'
          expect(response.status).to eq 400
        end
      end
    end
    describe 'pagination' do
      context 'when asking for the first page' do
        it 'renders the 2 first items' do
          get '/api/publishers?page=1&per=2'
          expect(json_body['data'].map { |h| h['id'] }).to contain_exactly(publisher1.id, publisher2.id)
        end
      end
      context 'when asking for the second page' do
        it 'renders the last item' do
          get '/api/publishers?page=2&per=2'
          expect(json_body['data'].last['id']).to eq publisher3.id
        end
      end
      context 'when sending invalid "page" and "per" parameters' do
        it 'renders error status' do
          get '/api/publishers?page=toto&per=toto'
          expect(response.status).to eq 400
        end
      end
    end

    describe 'sorting' do
      context 'with valid column name "id"' do
        it 'renders publishers sorted by ids' do
          get '/api/publishers?sort=id&dir=asc'
          expect(json_body['data'].first['id']).to eq publisher1.id
        end
      end
      context 'with invalid column name "fid"' do
        it 'renders errors status' do
          get '/api/publishers?sort=fid&dir=fid'
          expect(response.status).to eq 400
        end
      end
    end

    describe 'filtering' do
      context 'with valid filtering param "q[name_cont]=the"' do
        it "renders the publisher with 'the' inside the title" do
          get '/api/publishers?q[name_cont]=the'
          expect(json_body['data'].first['name']).to eq 'the publisher'
          expect(json_body['data'].count).to eq 1
        end
      end
      context 'with invalid filtering param "q[fname_cont]=the"' do
        it 'renders error status' do
          get '/api/publishers?q[fname_cont]=the'
          expect(response.status).to eq 400
        end
      end
    end
  end

  describe 'GET /api/publishers/:id' do
    context 'with existing resource' do
      it 'renders the publisher' do
        get "/api/publishers/#{publisher1.id}"
        puts response.body
        expect(json_body['data']['id']).to eq publisher1.id
      end
    end

    context 'with nonexistent resource' do
      it 'renders error 404' do
        get '/api/publishers/1234'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/publishers' do
    context 'with valid parameters' do
      let(:params) { { data: { name: 'the new publisher' } } }
      it 'renders the new publisher' do
        post '/api/publishers', params: params
        expect(json_body['data']['name']).to eq 'the new publisher'
      end

      it 'creates a new publisher' do
        expect { post '/api/publishers', params: params }.to change { Publisher.count }.by(1)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { data: { name: '' } } }
      it 'does not create any publisher' do
        post '/api/publishers', params: params
        expect(response.status).to eq 422
      end
    end
  end

  describe 'PATCH /api/publishers/:id' do
    context 'with valid parameters' do
      let(:params) { { data: { name: 'other publisher' } } }
      it 'renders the modified publisher' do
        patch "/api/publishers/#{publisher1.id}", params: params
        expect(json_body['data']['name']).to eq 'other publisher'
      end
    end
    context 'with invalid parameters' do
      let(:params) { { data: { name: '' } } }
      it 'renders errors 422' do
        patch "/api/publishers/#{publisher1.id}", params: params
        expect(response.status).to eq 422
      end
    end
  end

  describe 'DELETE /api/publishers/:id' do
    context 'with existing resource' do
      it 'remove the publisher' do
        delete "/api/publishers/#{publisher1.id}"
        expect(response.status).to eq 204
        expect(Publisher.count).to eq 2
      end
    end
    context 'with nonexistent resource' do
      it 'renders not found status' do
        delete '/api/publishers/1234'
        expect(response.status).to eq 404
      end
    end
  end
end
