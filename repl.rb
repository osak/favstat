#!/usr/bin/env ruby

require_relative 'node'
require_relative 'favstat'
require_relative 'feature'

THRESHOLD = 0.5832

tree = Marshal.load(File.open("tree.bin"))
dict = Feature.load_dict("feature_words.txt")

Node.threshold = THRESHOLD
loop do
  print "> "
  line = gets.chomp
  feature_vec = Feature.extract(line, dict)
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
