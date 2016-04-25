FactoryGirl.define do
  factory :task do
    name 'Super task'
    description 'description'
    user
  end
end
