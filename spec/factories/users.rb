FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  sequence :name do |n|
    "Super_user_#{n}"
  end

  factory :user do
    name
    email
    password 'qwerty123'
  end
end
