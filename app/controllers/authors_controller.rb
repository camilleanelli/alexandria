# frozen_string_literal: true

class AuthorsController < ApplicationController
  before_action :find_author, only: %i[show update destroy]

  def index
    authors = orchestrate_query(Author.all)
    render serialize(authors)
  end

  def show
    render serialize @author
  end

  def create
    author = Author.create(author_params)
    if author.save
      render serialize(author).merge(status: :created, location: author)
    else
      unprocessable_entity!(author)
    end
  end

  def update
    if @author.update(author_params)
      render serialize(@author).merge(status: :ok)
    else
      unprocessable_entity!(@author)
    end
  end

  def destroy
    @author.destroy
    render status: :no_content
  end

  private

  def find_author
    @author = Author.find_by!(id: params[:id])
  end

  def author_params
    params.require(:data).permit(:given_name, :family_name)
  end
end
