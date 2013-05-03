#!/usr/bin/env ruby

require_relative 'favstat'
require_relative 'db'
require 'MeCab'
require 'set'
require 'bson'

class Extractor
  def initialize(fname)
    @feature_words = {}
    File.read(fname).each_line.with_index do |line, nth|
      _, str = line.chomp.split(/\t/)
      @feature_words[str] = nth
    end
  end

  def process(list, fav, &blk)
    list.each do |tweet|
      feature = {}
      feature[:id] = tweet["id"]
      text = tweet["text"].dup
      feature[:url] = !!(text.match(FavStat::URL_PATTERN))
      text.gsub!(FavStat::URL_PATTERN, '')
      feature[:mention] = !!(text.match(FavStat::MENTION_PATTERN))
      text.gsub!(FavStat::MENTION_PATTERN, '')
      feature[:hashtag] = !!(text.match(FavStat::HASHTAG_PATTERN))
      text.gsub!(FavStat::HASHTAG_PATTERN, '')
      feature[:tweet_length] = text.length
      feature[:vec] = Array.new(@feature_words.size, false)
      (3..6).each do |n|
        text.ngrams(n).each do |ngram|
          if nth = @feature_words[ngram]
            feature[:vec][nth] = true
          end
        end
      end
      text.mecab_parsed.each do |node|
        if nth = @feature_words[node.surface]
          feature[:vec][nth] = true
        end
      end
      feature[:fav] = fav
      yield feature
    end
  end
end

db = DBConn.getdb("slopefav")
favs = db.collection("favs")
tweets = db.collection("tweets")
collection = db.collection("features")

non_fav_ids = File.read("non_fav_list.txt").lines.map{|a| BSON::ObjectId.from_string(a.chomp)}
fav_list = favs.find.to_a
non_fav_list = tweets.find({"_id" => {"$in" => non_fav_ids}}).to_a

extractor = Extractor.new("feature_words.txt")
callback = proc{|f| collection.insert(f)}
extractor.process(fav_list, true, &callback)
extractor.process(non_fav_list, false, &callback)
