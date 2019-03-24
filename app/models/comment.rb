class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user
  validates :content, presence: true, length: { minimum: 1, maximum: 140 }
end
