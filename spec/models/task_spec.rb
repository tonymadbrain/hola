require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe Task, type: :model do
  it { should validate_presence_of(:name) }
end
