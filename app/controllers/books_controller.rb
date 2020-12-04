# frozen_string_literal: true

class BooksController < ApplicationController
  def index
    books = orchestrate_query(Book.all)

    render serialize(books)
  end

  def show
    render serialize find_book
  end

  def create
    book = find_book
    if book.save
      # ici on ajoute à la réponse le status et la localisation de l'uri de la nouvelle ressource
      render serialize(book).merge(status: :created, location: book)
    else
      unprocessable_entity!(book)
    end
  end

  def update
    book = find_book
    if book.update(books_params)
      # on ajouter le status de l'erreur à la réponse
      render serialize(book).merge(status: :ok)
    else
      unprocessable_entity!(book)
    end
  end

  def destroy
    book = find_book
    book.destroy
    render status: :no_content
  end

  private

  def find_book
    @book ||= params[:id] ? Book.find_by!(id: params[:id]) : Book.new(books_params)
  end
  alias resource find_book

  def books_params
    params.require(:data).permit(:title, :subtitle, :isbn_10, :isbn_13, :description, :released_on, :publisher_id, :author_id, :cover)
  end
end
