class Node
  attr_reader :left, :right
  attr_reader :idx, :val
  attr_reader :result

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
      self.result = args.first
    else
      @left, @right, @idx, @val = args
    end
  end

  def result=(list)
    @result = list.dup
    @fav, @no_fav = @result.partition{|a| a["fav"]}.map(&:size)
    @prop = @fav.to_f / (@fav.to_f + @no_fav.to_f)
  end


  def judge(vec)
    if left && right
      if val.is_a?(Numeric)
        vec[idx] < val ? left : right
      else
        vec[idx] ? left : right
      end
    else
      @prop
    end
  end

  def to_s(level=0)
    indent = "  "*level
    if left && right
      op = val.is_a?(Numeric) ? '<' : '=='
      indent + "#{@@feature_name[idx]} #{op} #{@val}\n" + 
      indent + "T->\n" + left.to_s(level+1) +
      indent + "F->\n" + right.to_s(level+1)
    else
      indent + "#{@fav}/#{@no_fav})\n"
    end
  end

  def leaf?
    !!(left && right)
  end
end

