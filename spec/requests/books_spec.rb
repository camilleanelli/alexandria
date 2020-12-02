# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let!(:book1) { create(:book, title: 'title_1') }
  let!(:book2) { create(:book2) }
  let!(:book3) { create(:book3) }

  let(:books) { [book1, book2, book3] }

  describe 'GET /api/books' do
    context 'default behavior' do
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

  describe 'pagination ' do
    context 'when asking for the first page ' do
      before { get '/api/books?page=1&per=2' }

      it 'receives http status 200' do
        expect(response.status).to eq 200
      end

      it 'receives only two books' do
        expect(json_body['data'].size).to eq 2
      end

      it 'receives the response with the link header' do
        expect(response.header['Link'].split(', ').first).to eq(
          '<http://www.example.com/api/books?page=2&per=2>; rel="next"'
        )
      end
    end

    context 'when asking for the second page' do
      before { get('/api/books?page=2&per=2') }

      it 'receives HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives only one book' do
        expect(json_body['data'].size).to eq 1
      end
    end

    context 'when sending invalid page and per paramters' do
      before { get '/api/books?page=fake&per=2' }

      it 'receive http status 400' do
        expect(response.status).to eq(400)
      end
    end

    context 'when sending invalid params' do
      before { get '/api/books?page=fake&per=10' }

      it 'receives http status 400' do
        expect(response.status).to eq 400
      end

      it 'receives an error' do
        expect(json_body['error']).to_not be nil
      end

      it 'receives page=fake as an invalid params' do
        expect(json_body['error']['invalid_params']).to eq 'page=fake'
      end
    end
  end

  describe 'sorting' do
    context 'with valid parameters' do
      it 'sorts the books by id desc' do
        get('/api/books?sort=id&dir=desc')
        expect(json_body['data'].first['id']).to eq book3.id
        expect(json_body['data'].last['id']).to eq book1.id
      end
    end

    context 'with invalid column name fid' do
      before { get '/api/books?sort=fid&dir=asc' }

      it 'gets 400 bad request back' do
        expect(response.status).to eq 400
      end

      it 'receives an error' do
        expect(json_body['error']).to_not be nil
      end

      it 'receives sort=fid as invalid param' do
        expect(json_body['error']['invalid_params']).to eq 'sort=fid'
      end
    end
  end

  describe 'filtering' do
    context 'with valid filtering param "q[title_cont]=1"' do
      it 'receives title_1 back' do
        get('/api/books?q[title_cont]=1')
        expect(json_body['data'].first['id']).to eq book1.id
        expect(json_body['data'].size).to eq 1
      end
    end
    context 'with invalid filtering param "q[ftitle_cont]=Microscope"' do
      before { get('/api/books?q[ftitle_cont]=2') }

      it 'gets "400 Bad Request" back' do
        expect(response.status).to eq 400
      end

      it 'receives an error' do
        expect(json_body['error']).to_not be nil
      end

      it 'receives "q[ftitle_cont]=2" as an invalid param' do
        expect(json_body['error']['invalid_params']).to eq 'q[ftitle_cont]=2'
      end
    end
  end
end
