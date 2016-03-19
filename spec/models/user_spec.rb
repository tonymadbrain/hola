require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe User, type: :model do
  it { should respond_to(:name) }
  # it { should validate_presence_of(:name) }
  # it { should validate_presence_of(:email) }
  # it { should validate_presence_of(:password) }
  # it { should validate_length_of(:email).is_at_most(25) }
  # it { should validate_length_of(:password).is_at_most(1400) }
  # it { should validate_length_of(:email).is_at_least(5) }
  # it { should validate_length_of(:password).is_at_least(10) }
end
