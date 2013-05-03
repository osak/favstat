#!/usr/bin/env ruby

require_relative 'db'

db = DBConn.getdb("slopefav")
favs = db.collection("favs")
tweets = db.collection("tweets")

fav_ids = favs.find({}, fields: ["id"]).map{|a| a["id"]}
non_favs_cursor = tweets.find({"id" => {"$nin" => fav_ids}})
fav_list = favs.find().to_a
non_fav_list = []
non_favs_cursor.each_with_index do |tweet, idx|
  if non_fav_list.size < 5000
    non_fav_list << tweet
  else
    if rand < 5000.0/(idx+1)
      pos = (rand*5000).to_i
      non_fav_list[pos] = tweet
    end
  end
  puts idx if idx % 10000 == 0
end

puts non_fav_list.map{|a| a["_id"]}
