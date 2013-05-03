require 'MeCab'

module FavStat
  URL_PATTERN = /https?:\/\/[a-zA-Z0-9_\-.]+/.freeze
  MENTION_PATTERN = /@(?:[a-zA-Z0-9_]+)/.freeze
  HASHTAG_PATTERN = /(?:^| |　)#(?:\S+)/.freeze
end

class String
  def ngrams(n)
    Enumerator.new do |y|
      (0..self.size-n).each do |start|
        y << self[start,n]
      end
    end
  end

  def mecab_parsed
    mecab = MeCab::Model.new("")
    tagger = mecab.createTagger
    node = tagger.parseToNode(self)
    Enumerator.new do |y|
      while node
        y << node
        node = node.next
      end
    end
  end
end


