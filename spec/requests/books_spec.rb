# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Books', type: :request do
  before do
    allow_any_instance_of(BooksController).to(
      receive(:validate_auth_scheme).and_return(true)
    )
    allow_any_instance_of(BooksController).to(
      receive(:authenticate_client).and_return(true)
    )
  end

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

  describe 'GET /api/books/:id' do
    context 'with existing resource' do
      before { get "/api/books/#{book1.id}" }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end

      it 'receives the book1 as JSON' do
        expected = { data: BookPresenter.new(book1, {}).fields.embeds }
        expect(response.body).to eq(expected.to_json)
      end
    end

    context 'with nonexistent resource' do
      it 'gets HTTP status 404' do
        get '/api/books/2314323'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/books' do
    let(:author) { create(:oscar) }
    before { post '/api/books', params: { data: params } }

    context 'with valid params' do
      let(:params) do
        { title: 'my_new_book',
          author_id: author.id,
          released_on: '2020-10-04',
          isbn_10: '8' * 10,
          isbn_13: '5' * 13 }
      end

      it 'gets http status 201' do
        expect(response.status).to eq 201
      end

      it 'receives the newly created resource' do
        expect(json_body['data']['title']).to eq 'my_new_book'
      end

      it 'adds record in the database' do
        expect(Book.count).to eq 4
      end
    end

    context 'invalid parameters' do
      let(:params) do
        { title: '',
          author_id: '',
          released_on: '2020-10-04',
          isbn_10: '8' * 10,
          isbn_13: '5' * 13 }
      end

      it 'gets http status 422' do
        expect(response.status).to eq 422
      end

      it 'receives an error details' do
        expect(json_body['error']['invalid_params']).to eq(
          'title' => ["can't be blank"], 'author' => ['must exist', "can't be blank"]
        )
      end

      it 'does nor add a record in the database' do
        expect(Book.count).to eq 3
      end
    end
  end


describe 'PATCH /api/books/:id' do
  before { patch "/api/books/#{book1.id}", params: { data: params } }

  context 'with valid parameters' do
    let(:params) { { title: 'another_title' } }

    it 'gets http status 200' do
      expect(response.status).to eq 200
    end

    it 'receives the updated resource' do
      expect(json_body['data']['title']).to eq 'another_title'
    end

    it 'updates the record in the database' do
      expect(Book.first.title).to eq 'another_title'
    end
  end
  context 'with invalid parameters' do
    let(:params) { { title: '' } }

    it 'gets http status 422' do
      expect(response.status).to eq 422
    end

    it 'receives an error details' do
      expect(json_body['error']['invalid_params']).to eq(
        'title' => ["can't be blank"]
      )
    end

    it 'does not add a record in the database' do
      expect(Book.first.title).to eq 'title_1'
    end
  end
end

describe 'DELETE /api/books/:id' do
  context 'with existing resource' do
    before { delete "/api/books/#{book1.id}" }

    it 'gets HTTP status 204' do
      expect(response.status).to eq 204
    end
    it 'deletes the book from the database' do
      expect(Book.count).to eq 2
    end
  end

  context 'with nonexistent resource' do
    it 'gets HTTP status 404' do
      delete '/api/books/2314323'
      expect(response.status).to eq 404
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

  context 'with invalid field name "fid"' do
    before { get '/api/books?fields=fid,title,author_id' }
    it 'gets "400 Bad Request" back' do
      expect(response.status).to eq 400
    end

    it 'receives an error' do
      expect(json_body['error']).to_not be nil
    end

    it 'receives "fields=fid" as an invalid param' do
      expect(json_body['error']['invalid_params']).to eq 'fields=fid'
    end
  end # conte
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

describe 'embed picking' do
  context 'with the embed parameter' do
    before { get '/api/books?embed=author' }

    it 'gets the books with their authors embedded' do
      json_body['data'].each do |book|
        expect(book['author'].keys).to eq(
          %w[id given_name family_name created_at updated_at]
        )
      end
    end
  end

  context 'with invalid "embed" relation "fake"' do
    before { get '/api/books?embed=fake,author' }

    it 'gets "400 Bad Request" back' do
      expect(response.status).to eq 400
    end
    it 'receives an error' do
      expect(json_body['error']).to_not be nil
    end
    it 'receives "fields=fid" as an invalid param' do
      expect(json_body['error']['invalid_params']).to eq 'embed=fake'
    end
  end
end
