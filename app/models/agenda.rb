class Agenda < ApplicationRecord
  belongs_to :team
  belongs_to :user
  has_many :articles, dependent: :destroy
  validates :title, presence: true, uniqueness: true, length: { minimum: 1, maximum: 30 }
end
