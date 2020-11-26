# frozen_string_literal: true

FactoryBot.define do
  factory :oscar, class: Author do
    given_name { 'Oscar' }
    family_name { 'Wilde' }
  end

  factory :margaret, class: Author do
    given_name { 'Margaret' }
    family_name { 'Atwood' }
  end
  factory :amelie, class: Author do
    given_name { 'Amélie' }
    family_name { 'Nothombe' }
  end
end
