class String
  def clean
    split("").reject{|x| not x=~/[a-zA-Z]/}.join("").downcase
  end
end

def colorize(text, color_code = nil)
  return text unless color_code
  "\e[#{color_code}m#{text}\e[0m"
end

# def red(text); colorize(text, "e[31m"); end
# def green(text); colorize(text, "e[32m"); end
class Els
  attr_accessor :n, :d, :k, :color, :word
  def initialize(word,n,d,k,color)
    self.word = word
    self.n = n
    self.d = d
    self.k = k
    self.color = color
  end
  def indices
    (0...k).collect{|t| n+t*d}
  end
  def include?(i)
    indices.include?(i)
  end
  def to_s
    "ELS of #{self.word}: n=#{self.n}, d=#{self.d}, k=#{self.k}"
  end
  def inspect
    to_s
  end
end

class Text
  @@default_els_color = 44
  attr_accessor :text, :source
  def Text.from_file(filename)
    File.open(filename, "r"){|file| return Text.new(file.read)}
  end
  def initialize(source)
    @source = source
    @text = source.clean
  end 
  def find(word, max_jump)
    results = {}
    for d in 1..max_jump do
      regexp = Regexp.new(word.split("").collect{|s| s+"."*(d-1)}.join("")[0..-d])
      temp = @text.index(regexp)
      while temp != nil
	  results[d] ||= []
	  results[d] << temp
	  temp = @text.index(regexp, temp+1)
      end
    end
    results.collect{|d, arr| arr.collect{|n| Els.new(word,n,d,word.length,@@default_els_color)}}.flatten
  end
  def show(from, to, jump, els_array)
    base_color = 41
    column = 0
    for i in from..to do
      temp = els_array.find{|els| els.include?(i)}
      color = nil
      color = temp.color if temp != nil
      print colorize(@text[i..i],color)
      column += 1
      if column == jump
      column = 0
      puts
      end
    end
  end
#   def show(n,d,k,color)
#     gap = 30
#     a = [0, n-gap].max
#     b = [@text.length-1, n+d*(k-1)].min
#       subtext = @text[a..b]
#       pos = a
#       col = 0
#       while pos < b
# 	
#       end
#   end
end

t = Text.from_file("alice.txt")
# els = Els.new(100,5,20,42)
# t.show(80,200,5,[els])
# els.
puts t.find("rabin",200).inspect
# puts "Good morning #{colorize("world",42)}!"