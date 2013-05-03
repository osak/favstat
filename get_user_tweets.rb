#!/usr/bin/env ruby

require_relative 'db'
require_relative 'twitter'
require 'pp'

def with_retry(&blk)
  res = yield
  while res.is_a?(Hash)
    # Rate limit
    puts "Rate limit"
    sleep(300)
    res = yield
  end
  res
end

db = DBConn.getdb("slopefav")
collection = db.collection("tweets")
tw = Twitter.new
users = File.read("users.txt").lines
users.each do |user|
  max_id = nil
  puts "#{user}"
  sum = 0
  5.times do
    opt = {count: 200}
    opt[:max_id] = max_id if max_id
    tweets = with_retry{tw.user_timeline(user, opt)}
    collection.insert(tweets)
    sum += tweets.size
    puts "\t#{sum}"
    max_id = tweets.last['id']
  end
end
