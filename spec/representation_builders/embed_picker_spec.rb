# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EmbedPicker' do
  let(:author) { create(:oscar, given_name: 'Oscar Wilde') }
  let(:book) do
    create(:book, author_id: author.id)
  end
  let(:book2) { create(:book2, author_id: author.id) }
  let(:params) { {} }
  let(:embed_picker) { EmbedPicker.new(presenter) }

  describe '#embed' do
    context 'with bookss as the resource' do
      let(:presenter) { BookPresenter.new(book2, params) }
      before do
        allow(BookPresenter).to receive(:relations).and_return(['author'])
      end

      context 'with no "embed" parameter' do
        it 'returns the "data" hash without changing it' do
          expect(embed_picker.embed.data).to eq presenter.data
        end
      end

      context 'with invalid relation "something"' do
        let(:params) { { embed: 'something' } }
        it 'raises a "RepresentationBuilderError"' do
          expect { embed_picker.embed }.to raise_error(RepresentationBuilderError)
        end
      end

      context 'with the embed parameter containing author' do
        let(:params) { { embed: 'author' } }

        it 'embeds the author data' do
          expect(embed_picker.embed.data[:author]).to eq(
            'id' => book2.author.id,
            'given_name' => 'Oscar Wilde',
            'family_name' => book2.author.family_name,
            'created_at' => book2.author.created_at,
            'updated_at' => book2.author.updated_at
          )
        end
      end

      context 'with the embed parameter containing books' do
        let(:params) { { embed: 'books' } }
        let(:presenter) { AuthorPresenter.new(author, params) }

        before do
          book && book2
          allow(AuthorPresenter).to receive(:relations).and_return(['books'])
        end

        it 'embeds the "books" data' do
          expect(embed_picker.embed.data[:books].size).to eq(2)
          expect(embed_picker.embed.data[:books].first['id']).to eq(book.id)
          expect(embed_picker.embed.data[:books].last['id']).to eq(book2.id)
        end
      end
    end
  end
end
