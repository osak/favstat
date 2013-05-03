#!/usr/bin/env ruby

require_relative 'favstat'
require_relative 'db'
require 'MeCab'

freq_dict = Hash.new{|h,k| h[k] = 0}
File.read("favs.txt").each_line do |line|
  line.chomp!
  has_url = (line =~ FavStat::URL_PATTERN)
  has_reply = (line =~ FavStat::MENTION_PATTERN)
  has_hashtag = (line =~ FavStat::HASHTAG_PATTERN)
  line.gsub!(FavStat::URL_PATTERN, '')
  line.gsub!(FavStat::MENTION_PATTERN, '')
  line.gsub!(FavStat::HASHTAG_PATTERN, '')
  (3..6).each do |n|
    line.ngrams(n).each do |ngram|
      freq_dict[ngram] += 1
    end
  end
  line.mecab_parsed.each do |node|
    freq_dict[node.surface] += 1 if node.surface.length >= 3
  end
end

# Top 400 を候補にする(適当)
list = freq_dict.to_a.sort_by{|a| a[1]}.reverse[0,400]
# 完全に他に包含されているものは弾く
list_uniq = list.reject{|a| list.any?{|b| a != b && b[0].index(a[0])}}

puts list_uniq.map{|a| "#{a[1]}\t#{a[0]}"}
