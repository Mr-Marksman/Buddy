FactoryBot.define do
  factory :post do
    title { "test_title" }
    description { "test_descriprion" }
    association :user
  end
end