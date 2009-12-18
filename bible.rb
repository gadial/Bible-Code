
class Array
  def choose_at_random
    self[rand(length)]
  end
  def pairs
    result = []
    each_index do |i|
      for j in 0...i do
	result << [self[i],self[j]]
      end
    end
    result
  end
end
class Hash
  def key_pairs
    keys.pairs
  end
end
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
  def start_point
    n
  end
  def end_point
    n+(k-1)*d
  end
  def to_s
    "ELS of #{self.word}: n=#{self.n}, d=#{self.d}, k=#{self.k}"
  end
  def inspect
    to_s
  end
  def distance(rhs,d)
    indices.collect do |i|
      rhs.indices.collect{|j| ((i%d)-(j%d)).abs + ((i/d)-(j/d)).abs}.min
    end.min
  end
  def min_distance(rhs)
    (1..50).collect{|d| [distance(rhs,d),d]}.sort.min
  end
  def <=>(rhs)
    self.word <=> rhs.word
  end
end

class Text
  @@default_els_color = 45
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
  def find_min(word, max_jump)
    result = []
    for d in 2..max_jump do
      regexp = Regexp.new(word.split("").collect{|s| s+"."*(d-1)}.join("")[0..-d])
      temp = @text.index(regexp)
      while temp != nil
	  result << temp
	  temp = @text.index(regexp, temp+1)
      end
      return result.collect{|n| Els.new(word,n,d,word.length,@@default_els_color)} unless result.empty?
    end    
    return []
  end
  def show(from, to, jump, els_array)
    base_color = 43
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
    puts unless column == 0
  end
  def to_s
    @text
  end
end

class Organizer
  @@max_jump = 200
  attr_accessor :text, :words
  def Organizer.from_file(filename)
    Organizer.new(Text.from_file(filename))
  end
  def initialize(text)
    self.text = text
    self.words = {}
  end
  def read_words_from_file(filename)
    File.open(filename, "r"){|file| file.read.split("\n")}.each do |word|
      temp = self.text.find_min(word, @@max_jump)
      self.words[word] = temp unless temp.empty?
    end
  end
  def words_found
    self.words.collect{|key, item| key}
  end
  def inspect
    self.words.inspect
  end
  def min_distance(word_1,word_2)
    els_1 = self.words[word_1]
    els_2 = self.words[word_2]
    return nil if els_1 == nil or els_2 == nil
    distances = []
    els_1.each{|e1| els_2.each{|e2| distances << [e1.min_distance(e2),e1,e2]}}
    return distances.min{|a,b| a[0] <=> b[0]}
  end
  def show_word_pair(word_1, word_2, d = nil)
      distance_info = min_distance(word_1,word_2)
      els_1 = distance_info[1]
      els_2 = distance_info[2]
      d = [els_1.d, els_2.d,distance_info[0][1]].max if d == nil
      self.text.show([els_1.start_point,els_2.start_point].min - 10,[els_1.end_point,els_2.end_point].max + 10,d,[els_1,els_2])
  end
  def get_random_els
      self.words.to_a.choose_at_random.last.choose_at_random
  end
  def find_pair_distances
    self.words.key_pairs.collect{|pair| [min_distance(pair[0],pair[1]),pair[0],pair[1]]}.sort
  end
  def color_word(word, color)
    self.words[word].each{|els| els.color = color}
  end
end



#o = Organizer.from_file("alice.txt")
#o.read_words_from_file("words.txt")
# # puts 
# puts o.words_found.inspect
# o.find_pair_distances.find_all{|p| p[0][0][0] < 50}.each{|p| puts p.inspect}
# o.color_word("obama",46)
# o.show_word_pair("death","obama")
# a = o.get_random_els
# b = o.get_random_els
# 
# o.show_word_pair(a.word,b.word)
# puts a.inspect
# puts b.inspect
# puts a.min_distance(b).inspect
# puts o.min_distance(a.word,b.word).inspect




# t = Text.from_file("alice.txt")
# # els = Els.new(100,5,20,42)
# # t.show(80,200,5,[els])
# # els.
# els_array = t.find_min("gadi",300)
# puts els_array.inspect
# temp = els_array.first
# t.show(temp.start_point - 50, temp.end_point + 50, temp.d+10, els_array) unless temp == nil
# 
# puts "Good morning #{colorize("world",42)}!"