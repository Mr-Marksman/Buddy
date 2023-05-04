FactoryBot.define do
  factory :user do
    email { "test@test.test" }
    name { "test" }
    password { "password" }
  end
end