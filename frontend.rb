#!/usr/bin/env ruby

ROOT = File.expand_path(File.dirname(__FILE__))

require 'sinatra'
require 'bson'
require 'cgi'
require 'json'
require_relative 'node'
require_relative 'feature'

path = File.join(ROOT, "tree.bin")
tree = Marshal.load(File.open(path))
dict = Feature.load_dict(File.join(ROOT, "feature_words.txt"))

get '/slopefav' do
  query = CGI.unescape(params[:q])
  feature_vec = Feature.extract(query, dict)
  cur = tree
  while cur.is_a?(Node)
    cur = cur.judge(feature_vec)
  end
  res = {q: query, result: cur}.to_json
end
