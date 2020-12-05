# frozen_string_literal: true

class PublishersController < ApplicationController
  before_action :find_publisher, only: %i[show update destroy]
  def index
    publishers = orchestrate_query(Publisher.all)

    render serialize(publishers)
  end

  def show
    render serialize(@publisher)
  end

  def create
    publisher = Publisher.create(publisher_params)
    if publisher.save
      render serialize(publisher).merge(status: :created, location: publisher)
    else
      unprocessable_entity!(publisher)
    end
  end

  def update
    if @publisher.update(publisher_params)
      render serialize(@publisher).merge(status: :ok, location: @publisher)
    else
      unprocessable_entity!(@publisher)
    end
  end

  def destroy
    @publisher.destroy
    render status: :no_content
  end

  private

  def find_publisher
    @publisher = Publisher.find_by!(id: params[:id])
  end

  def publisher_params
    params.require(:data).permit(:name)
  end
end
