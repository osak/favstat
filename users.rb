#!/usr/bin/env ruby

require_relative 'db'
require_relative 'twitter'
require 'pp'

db = DBConn.getdb("slopefav")
collection = db.collection("favs")
res = collection.find({}, fields: ["user.screen_name"])
users = res.map{|a| a["user"]["screen_name"]}
users.uniq!
puts users
puts users.size
