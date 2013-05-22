require 'mongoid'

class Bookmark
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :entry
end
