# frozen_string_literal: true

class Author < ApplicationRecord
  include PgSearch::Model
  multisearchable against: %i[given_name family_name]

  has_many :books

  validates :given_name, presence: true
  validates :family_name, presence: true
end
