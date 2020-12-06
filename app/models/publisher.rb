# frozen_string_literal: true

class Publisher < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name]

  has_many :books
  validates :name, presence: true
end
