# -*- encoding: utf-8 -*-
require 'net/http'
require 'json'
require 'oauth'

class Twitter
  load("~/.twitter_token")
  TWITTER_API = 'https://api.twitter.com/1.1/'

  def initialize
    @consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site=>'https://api.twitter.com')
    @access_token = OAuth::AccessToken.new(@consumer, ACCESS_TOKEN, ACCESS_SECRET)
  end

  def get(resource, *opt)
    opt_str = ''
    if !opt.empty?
      opt_arr = []
      opt[0].each_pair { |key, val|
        opt_arr << "#{URI.escape(key.to_s)}=#{URI.escape(val.to_s)}" if val
      }
      opt_str = '?'+opt_arr.join('&')
    end

    @access_token.get(TWITTER_API+resource+opt_str).body
  end

  def post(resource, data)
    @access_token.post(TWITTER_API+resource, data).body
  end

  def home_timeline(since=nil)
    args = {}
    args['since_id'] = since if since
    args['count'] = 200
    #args['trim_user']=1
    arr = []
    1.upto(4) do |page|
      args['page'] = page
      ret = self.get('statuses/home_timeline.xml', args)
      doc = REXML::Document.new(ret)
      doc.root.elements.each { |status|
        arr << Tweet.new(status)
      }
      break if doc.root.elements.size < args['count']
    end
    arr.reverse
  end

  def mentions(since=nil, *opt)
    args = {}
    args['since_id'] = since if since
    args['count'] = 200
    #args['trim_user'] = 1
    args.merge!(opt[0]) if opt.size > 0
    arr = []
    1.upto(4) do |page|
      args['page'] = page
      ret = self.get('statuses/mentions.json', args)
      doc = JSON.parse(ret)
      doc.each do |entry|
        arr << entry
      end
    end

    arr
  end

  def tweet(msg, in_reply_to=nil)
    arg = {'status'=>msg}
    arg['in_reply_to_status_id'] = in_reply_to if in_reply_to
    self.post('statuses/update.xml', arg)
  end

  def followers(cursor)
    arg = {}
    arg['cursor'] = cursor if cursor
      self.get('statuses/followers.xml', arg)
  end

  def followers_id
    ret = self.get('followers/ids.xml')
    doc = REXML::Document.new(ret)
    doc.root.elements.map { |elem| elem.text.to_i }
  end

  def follow(id)
    self.post('friendships/create.xml', {'user_id' => id})
  end

  def user_timeline(name, *opt)
    args = {'screen_name' => name}
    args.merge!(opt.first) if opt.size > 0

    ret = self.get('statuses/user_timeline.json', args)
    doc = JSON.parse(ret) rescue []
  end

  def all_list(*opt)
    args = {}
    args.merge!(opt[0]) if opt.size > 0

    ret = self.get('lists/all.json', args)
    JSON.parse(ret)
  end

  def add_to_list(list_id, screen_name)
    args = {'list_id' => list_id, 'screen_name' => screen_name}

    ret = self.post('lists/members/create.json', args)
    JSON.parse(ret)
  end

  def remove_from_list(list_id, screen_name)
    args = {'list_id' => list_id, 'screen_name' => screen_name}

    ret = self.post('lists/members/destroy.json', args)
    JSON.parse(ret)
  end

  def members_of_list(list_id, *opt)
    args = {'list_id' => list_id}
    args.merge!(opt[0]) if opt.size > 0

    ret = self.get('lists/members.json', args)
    JSON.parse(ret)
  end

  def stream(resource, *args, &blk)
    opt = {}
    opt.merge!(args.first) if args.size > 0
    consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site=>'https://userstream.twitter.com')
    access_token = OAuth::AccessToken.new(consumer, ACCESS_TOKEN, ACCESS_SECRET)
    http = access_token.consumer.http
    http.ssl_version = 'TLSv1'
    #request = access_token.consumer.create_signed_request(:post, '/1/statuses/filter.json', access_token, {}, opt, {
    request = access_token.consumer.create_signed_request(:get, '/2/user.json', access_token, {}, opt, {
      'Host' => 'userstream.twitter.com', 'User-Agent' => 'MyStreamer(osak.63@gmail.com)'})
    request.each_header do |name,val|
      puts "#{name}: #{val}"
    end
    http.request(request) { |res|
      puts "response"
      res.read_body(&blk)
    }
    #access_token.post("https://stream.twitter.com/1/statuses/filter.json", opt)
  end

  def favorites(*opt)
    args = {}
    args.merge!(opt[0]) if opt.size > 0

    JSON.parse(self.get('favorites/list.json', args))
  end
end
