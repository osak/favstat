#!/usr/bin/env ruby

require 'mongo'
require 'pp'
require_relative 'twitter'

include Mongo

conn = Connection.new
db = conn.db("slopefav")
collection = db.collection("favs")

tw = Twitter.new
max_id = nil
lastone = collection.find.to_a.last
if lastone
  max_id = lastone["id"]-1
end
sum = 0
loop do
  puts "max_id: #{max_id}"
  opt = {screen_name: "slope81", count: 200}
  opt[:max_id] = max_id if max_id
  favs = tw.favorites(opt)
  pp favs
  if favs.is_a?(Array)
    collection.insert(favs)
    sum += favs.size
    puts "#{favs.size} / #{sum}"
    max_id = favs.last['id']-1
  else
    puts "Rate limit"
    exit
  end
end
