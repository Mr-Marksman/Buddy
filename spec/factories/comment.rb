FactoryBot.define do
  factory :comment do
    body { "This is a comment body." }
    user

    association :post, factory: :post
  end
end