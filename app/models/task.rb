class Task < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true, length: { maximum: 25, minimum: 5 }
  validates :description, presence: true, length: { maximum: 1400, minimum: 10 }
  after_initialize :init

  def init
    self.state  ||= 'new'           #will set the default value only if it's nil
  end
end
