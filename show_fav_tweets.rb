#!/usr/bin/env ruby

require_relative 'db'

db = DBConn.getdb("slopefav")
collection = db.collection("favs")
collection.find.each do |elem|
  puts elem["text"]
end
