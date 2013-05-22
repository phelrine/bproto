$:.unshift File.dirname(File.dirname(File.expand_path __FILE__))
require 'database'

# initialize database
User.delete_all;
Bookmark.delete_all;
Entry.delete_all;

usernames = ['phelrine', 'friend_A', 'friend_B', 'other_A', 'other_B']
urls = [
  'http://twitter.github.io/bootstrap/',
  'http://www.sinatrarb.com/',
  'http://gihyo.jp/dev/serial/01/machine-learning',
  'http://www.em.ci.ritsumei.ac.jp/',
  'http://intern.hatenastaff.com/']
# make users
users = usernames.map{|name|
  users = User.create(username: name)
}

follow_matrix = [
  [0, 1, 1, 0, 0],
  [1, 0, 0, 0, 1],
  [1, 1, 0, 0, 0],
  [0, 0, 0, 0, 1],
  [0, 0, 0, 1, 0]
]

bookmark_matrix = [
  [0, 0, 1, 1, 0],
  [0, 1, 1, 0, 1],
  [1, 1, 1, 0, 1],
  [1, 0, 1, 1, 1],
  [0, 1, 1, 1, 1]
]

follow_matrix.each_with_index{|arr, i|
  arr.each_with_index{|v, j|
    users[i].follow(users[j]) if v == 1
  }
}

bookmark_matrix.each_with_index{|arr, i|
  arr.each_with_index{|v, j|
    users[i].bookmark(urls[j]) if v == 1
  }
}
