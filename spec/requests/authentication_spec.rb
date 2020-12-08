# frozen_string_literal: true

# spec/requests/authentication_spec.rb
require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'Client Authentication' do
    before { get '/api/books', headers: headers }

    context 'with invalid authentication scheme' do
      let(:headers) { { 'HTTP_AUTHORIZATION' => '' } }

      it 'gets HTTP status 401 Unauthorized' do
        expect(response.status).to eq 401
      end
    end

    context 'with valid authentication scheme' do
      let(:headers) do
        { 'HTTP_AUTHORIZATION' => "Alexandria-Token api_key=#{key}" }
      end

      context 'with invalid api key' do
        let(:key) { 'fake' }
        it 'gets http status 401 Unauthorized' do
          expect(response.status).to eq 401
        end
      end

      context 'with disabled api key' do
        let(:key) { ApiKey.create.tap(&:disable).key }
        it 'gets http status 401 Unauthorized' do
          expect(response.status).to eq 401
        end
      end

      context 'with valid api key' do
        let(:key) { ApiKey.create.key }
        it 'gets http status 200' do
          expect(response.status).to eq 200
        end
      end
    end
  end
end
