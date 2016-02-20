require File.expand_path '../../spec_helper.rb', __FILE__

describe Task do
  it { should validate_presence_of :name }
end
