# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    title { 'Le portrait de Doriane Grey' }
    subtitle { 'MyText' }
    isbn_10 { '1937785564' }
    isbn_13 { '9781937785567' }
    description { 'MyText' }
    released_on { '2020-11-25' }
    publisher
    author { association :oscar }
  end

  factory :book2, class: Book do
    title { 'La servante écarlate' }
    subtitle { 'MyText' }
    isbn_10 { '0134077709' }
    isbn_13 { '9780134077703' }
    description { 'MyText' }
    released_on { '2020-11-25' }
    publisher
    author { association :margaret }
  end

  factory :book3, class: Book do
    title { 'Stupeur et tremblements' }
    subtitle { 'MyText' }
    isbn_10 { '1593275617' }
    isbn_13 { '9781593275617' }
    description { 'MyText' }
    released_on { '2020-11-25' }
    publisher
    author { association :amelie }
  end
end
