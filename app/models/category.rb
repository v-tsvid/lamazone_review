class Category < ActiveRecord::Base
  validates :title, presence: true, uniqueness: true

  has_and_belongs_to_many :books
end
