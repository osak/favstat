#!/usr/bin/env ruby

require_relative 'db'
require_relative 'node'
require 'pry'

LOG2 = Math.log(2)

def entropy(list)
  results = list.reduce({true => 0, false => 0}){|h, a| h[a["fav"]] += 1; h}
  entropy = 0.0
  results.each_pair do |key, val|
    val /= list.size.to_f
    entropy -= val * Math.log(val) / LOG2
  end
  entropy
end

def vals(list, i)
  type = list.first["vec"][i].class
  if type == TrueClass || type == FalseClass
    [true]
  else
    list.map{|a| a["vec"][i]}.uniq
  end
end

def get_pred(val)
  if val.is_a?(Numeric)
    lambda{|a| a < val}
  else
    lambda{|a| a}
  end
end

def build_tree(list, depth=0)
  if list.size == 0
    return Node.new([])
  end
  if depth == 30
    return Node.new(list)
  end

  current_score = entropy(list)

  best_gain = 0.0
  best_criteria = nil
  best_sets = nil

  nfeatures = list[0]["vec"].size
  nfeatures.times do |i|
    feature_vals = vals(list, i)
    feature_vals.each do |thresh|
      pred = get_pred(thresh)
      # i 番目の素性で分類する
      left, right = list.partition{|e| pred.call(e["vec"][i])}
      # 情報ゲイン
      pval = left.size / list.size.to_f
      gain = current_score - pval*entropy(left) - (1-pval)*entropy(right)
      if gain > best_gain && left.size > 0 && right.size > 0
        best_gain = gain
        best_criteria = [i, thresh]
        best_sets = [left, right]
      end
    end
  end
  # 次の枝
  if best_gain > 0
    left = build_tree(best_sets[0], depth+1)
    right = build_tree(best_sets[1], depth+1)
    Node.new(left, right, best_criteria[0], best_criteria[1])
  else
    Node.new(list)
  end
end

def prune(node, mingain)
  if node.leaf?
    return
  end

  # ここに来たら葉ではない
  left = node.left.result
  right = node.right.result
  merged = left + right
  delta = entropy(merged) - (entropy(left)+entropy(right)) / 2

  if delta < mingain
    node.left = node.right = nil
    node.result = merged
  end
end

feature_names = File.read("feature_words.txt").lines.map{|l| l.chomp.split[1]}
db = DBConn.getdb("slopefav")
features = db.collection("features")
feature_list = features.find.to_a

feature_names << "url" << "mention" << "hashtag" << "length" << "non-kana"
Node.feature_name = feature_names
fav_count, no_fav_count = feature_list.partition{|a| a["fav"]}.map(&:size)
puts Node.threshold = fav_count.to_f / no_fav_count.to_f

puts "Building..."
tree = build_tree(feature_list)
puts "Pruneing..."
prune(tree, 0.1)

puts "Outputing..."
File.open("tree.txt", "w") do |f|
  f.puts tree.to_s
end
File.open("tree.bin", "w") do |f|
  Marshal.dump(tree, f)
end
