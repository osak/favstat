#!/usr/bin/env ruby

require_relative 'favstat'
require_relative 'db'
require_relative 'feature'
require 'MeCab'
require 'set'
require 'bson'

def process(list, dict, fav, &blk)
  list.each do |tweet|
    feature = {}
    feature[:id] = tweet["id"]
    feature[:fav] = fav
    feature[:vec] = Feature.extract(tweet["text"], dict)
    yield feature
  end
end

db = DBConn.getdb("slopefav")
favs = db.collection("favs")
tweets = db.collection("tweets")
collection = db.collection("features")

non_fav_ids = File.read("non_fav_list.txt").lines.map{|a| BSON::ObjectId.from_string(a.chomp)}
fav_list = favs.find.to_a
non_fav_list = tweets.find({"_id" => {"$in" => non_fav_ids}}).to_a

dict = Feature.load_dict("feature_words.txt")
callback = proc{|f| collection.insert(f)}
process(fav_list, dict, true, &callback)
process(non_fav_list, dict, false, &callback)
