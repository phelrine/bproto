require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  has_many :bookmarks
  has_and_belongs_to_many :following, class_name: 'User', inverse_of: :followers, autosave: true
  has_and_belongs_to_many :followers, class_name: 'User', inverse_of: :following


  def self.find_by_name(name)
    User.where(username: name).first
  end

  def bookmark(url)
    entry = Entry.where(url: url).first
    unless entry
      entry = Entry.create(url: url)
      entry.fetch
    end
    bookmark = self.bookmarks.where(entry: entry);

    return bookmark.first if bookmark.exists?
    return Bookmark.create(user: self, entry: entry)
  end

  def follow(user)
    if self.id != user.id && !self.following.include?(user)
      self.following << user
    end
  end

  def unfollow(user)
    self.following.delete(user)
  end

  def friend_ids
    @frineds ||= self.following.map{|u| u.username}
    friend << self.id
  end

  def bookmark_ids
    @bookmark_ids ||= self.bookmarks.map{|b| b.entry}
  end

  def remove_bookmarked(bookmarks)
    bookmarks.delete_if{|k, v|
      self.bookmark_ids.include? k
    }
  end

  def friend_filtering
    count = Hash.new(0)
    self.following.each{|user|
      user.bookmark_ids.each{|b| count[b] += 1}
    }
    Hash[*remove_bookmarked(count).sort_by{|k, v| -v}.flatten].keys
  end

  def collaborative_filtering
    users = User.all.inject({}){|h, u|
      h[u] = self.bookmark_similarity(u)
      h
    }.delete_if{|k, v| v < 0.7}
    p users
    users.delete self.id
    count = Hash.new(0)
    users.each{|k, v|
      k.bookmark_ids.each{|b| count[b] = 1}
    }
    count = remove_bookmarked(count).inject({}){|r, (k, v)|
      coeff = Math::log(1 + Bookmark.all.size / k.bookmarks.size)
      r[k] = v * coeff
      r
    }
    Hash[*count.sort_by{|k, v| -v}.flatten].keys
  end

  def bookmark_similarity(user)
    b1 = self.bookmark_ids
    b2 = user.bookmark_ids
    Similarity.cosine_boolean(b1, b2)
  end

  def friend_similarity(user)
    f1 = self.friend_ids
    f2 = user.friend_ids
    Similarity.cosine_boolean(f1, f2)
  end
end
