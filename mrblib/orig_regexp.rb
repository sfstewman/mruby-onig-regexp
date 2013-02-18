class OnigRegexp
  def self.compile(*args)
    self.new(*args)
  end

  # ISO 15.2.15.7.8
  attr_reader :source

  def self.last_match
    return @last_match
  end

  def ===(str)
    return self.match(str) ? true : false
  end

  def =~(str)
    m = self.match(str)
    return m ? m.begin(0) : nil
  end
end

class OnigMatchData
  # ISO 15.2.16.3.11
  attr_reader :string

  def initialize
    @data = []
    @string = ""
  end

  def push(beg = nil, len = nil)
    if (beg && len)
      @data.push(beg: beg, len: len)
    else
      @data.push(nil)
    end
  end

  # ISO 15.2.16.3.2
  def begin(index)
    d = @data[index]
    return (d && d[:beg])
  end

  # ISO 15.2.16.3.4
  def end(index = 0)
    d = @data[index]
    return (d && (d[:beg] + d[:len]))
  end

  # ISO 15.2.16.3.1
  def [](index)
    d = @data[index]
    return (d && @string.slice(d[:beg], d[:len]))
  end

  # ISO 15.2.16.3.8
  def post_match
    d = @data[0]
    return @string.slice(d[:beg] + d[:len] .. -1)
  end

  # ISO 15.2.16.3.9
  def pre_match
    return @string.slice(0, @data[0][:beg])
  end

  # ISO 15.2.16.3.7
  def offset(index)
    d = @data[index]
    return (d && [ d[:beg], d[:beg] + d[:len] ])
  end

  # ISO 15.2.16.3.13
  def to_s
    return self[0]
  end

  def length
    return @data.length
  end

  def size
    return @data.size
  end
end

class String
  def =~(a)
    (a.class.to_s == 'String' ?  Regexp.new(a.to_s) : a) =~ self
  end
  alias_method :old_sub, :sub
  def sub(a, s)
    m = (a.class.to_s == 'String' ?  Regexp.new(a.to_s) : a).match(self)
    r = ''
    if m.size == 0
      return nil
    end
    b, e = m.begin(0), m.end(0)
    r += self[0..b].to_s
    r += s
    r += self[e..-1]
    r
  end
  def split(a)
    ss = self
    r = []
    while true
      begin
        m = a.match(ss)
      rescue
        m = nil
      end
      if m == nil || m.size == 0
        break
      end
      b, e = m.begin(0), m.end(0)
      r << ss[0..b].to_s
      ss = ss[e..-1]
    end
    r << ss
    r
  end
end

Regexp=OnigRegexp

# This is based on https://github.com/masamitsu-murase/mruby-hs-regexp