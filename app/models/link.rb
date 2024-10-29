class Link < ApplicationRecord
  belongs_to :category, optional: true
end
