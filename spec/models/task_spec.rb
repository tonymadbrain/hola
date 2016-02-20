require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe Task, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it { should validate_length_of(:name).is_at_least(25) }
  it { should validate_length_of(:description).is_at_least(1400) }
end
