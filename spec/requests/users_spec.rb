# frozen_string_literal: true

# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    allow_any_instance_of(UsersController).to(
      receive(:validate_auth_scheme).and_return(true)
    )
    allow_any_instance_of(UsersController).to(
      receive(:authenticate_client).and_return(true)
    )
  end

  let!(:john) { create(:user) }

  describe 'GET /api/users' do
    it 'returns all the users' do
      get '/api/users'
      puts json_body
      expect(json_body['data'].size).to eq 1
    end
  end

  describe 'GET /api/users/:id' do
    it 'returns the user' do
      get "/api/users/#{john.id}"
      expect(json_body['data']['id']).to eq john.id
    end
  end

  describe 'POST /api/users' do
    let(:params) { { data: { email: 'example@gmail.com', password: 'password', given_name: 'Hugh', family_name: 'Grant', role: 'user' } } }
    it 'creates a user' do
      expect { post '/api/users', params: params }.to change { User.count }.by(1)
    end
  end

  describe 'PATCH /api/users/:id' do
    let(:params) do
      { data: {
        given_name: 'James'
      } }
    end

    it 'updates the user' do
      patch "/api/users/#{john.id}", params: params
      expect(json_body['data']['given_name']).to eq 'James'
    end
  end

  describe 'DELETE /api/users/:id' do
    it 'removes the user' do
      delete "/api/users/#{john.id}"
      expect(response.status).to eq 204
      expect(User.count).to be 0
    end
  end
end
