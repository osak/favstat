module Feature
  class <<self
    def load_dict(name)
      dict = {}
      File.read(name).each_line.with_index do |line, idx|
        dict[line.chomp] = idx
      end
      dict
    end

    def extract(str, dict)
      feature_vec = Array.new(dict.size, false)
      str = str.dup

      feature_vec << !!(str.match(FavStat::URL_PATTERN))
      str.gsub!(FavStat::URL_PATTERN, '')
      feature_vec << !!(str.match(FavStat::MENTION_PATTERN))
      str.gsub!(FavStat::MENTION_PATTERN, '')
      feature_vec << !!(str.match(FavStat::HASHTAG_PATTERN))
      str.gsub!(FavStat::HASHTAG_PATTERN, '')
      feature_vec << str.length

      (3..6).each do |n|
        str.ngrams(n).each do |ngram|
          if nth = dict[ngram]
            feature_vec[nth] = true
          end
        end
      end
      str.mecab_parsed.each do |node|
        if nth = dict[node.surface]
          feature_vec[nth] = true
        end
      end
      feature_vec
    end
  end
end
