#!/usr/bin/env ruby

require_relative 'node'
require_relative 'favstat'

THRESHOLD = 0.5832

tree = Marshal.load(File.open("tree.bin"))
features = File.read("feature_words.txt").lines.map(&:chomp)
dict = {}
features.each_with_index do |val, idx|
  dict[val] = idx
end

Node.threshold = THRESHOLD
loop do
  print "> "
  line = gets.chomp
  feature_vec = Array.new(features.size, false)
  (3..6).each do |n|
    line.ngrams(n).each do |ngram|
      if nth = dict[ngram]
        feature_vec[nth] = true
      end
    end
  end
  line.mecab_parsed.each do |node|
    if nth = dict[node.surface]
      feature_vec[nth] = true
    end
  end
  feature_vec << false << false << false << line.length
  cur = tree
  loop do
    if cur.is_a?(Node)
      cur = cur.judge(feature_vec)
    else
      puts cur
      break
    end
  end
end
