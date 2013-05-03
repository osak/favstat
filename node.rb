class Node
  attr_reader :left, :right
  attr_reader :idx, :val
  #attr_reader :result

  class << self
    def feature_name=(val)
      @@feature_name = val.dup
    end

    def threshold=(t)
      @@threshold = t
    end
  end

  def initialize(*args)
    if args.size == 1
      #@result = args.first
      @fav, @no_fav = args.first.partition{|a| a["fav"]}.map(&:size)
      @prop = @fav.to_f / @no_fav.to_f
    else
      @left, @right, @idx, @val = args
    end
  end

  def judge(vec)
    if left && right
      if val.is_a?(Integer)
        vec[idx] < val ? left : right
      else
        vec[idx] ? left : right
      end
    else
      @prop > @@threshold
    end
  end

  def to_s(level=0)
    indent = "  "*level
    if left && right
        indent + "#{@@feature_name[idx]}, #{@val}\n" + 
        indent + "T->\n" + left.to_s(level+1) +
        indent + "F->\n" + right.to_s(level+1)
    else
      indent + "#{@fav}/#{@no_fav})\n"
    end
  end
end

