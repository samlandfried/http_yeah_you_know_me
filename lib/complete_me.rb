class CompleteMe

  attr_accessor :dictionary, :count

  def initialize 
    @dictionary = Node.new("")
    @count = 0
  end

  def insert word, parent_node = @dictionary
    first_letter = word[0]
    remainder = word[1..-1]

    # Decide when to insert new nodes
    # compare  first_letter to siblings (parent_node.children) last letter.
    # if they match, that sibling is our current node
    node = find_matching_child_node(parent_node.value + first_letter, parent_node)

    # if no match is found, create a new node.
    unless node
      node = Node.new(parent_node.value + first_letter)
      parent_node.children << node
    end

    if remainder.size > 0
      self.insert remainder, node
    else
      @count += 1
      node.word = true
    end
  end

  def find_matching_child_node target, node
    matching_node = nil
    node.children.each_with_index do |child_node, i|
      if target == child_node.value
        matching_node = node.children[i]
      end
    end
    matching_node
  end

  def insert_words words
    words.each do |word|
      self.insert(word)
    end
  end

  def populate words
    self.insert_words(words.split("\n"))
  end

  def find_node word
    node = @dictionary
    word.length.times do |pos|
      #search node's children for a match of substr[0, pos] (A portion of substr from 0 to trie level)
      target = word[0..pos]
      #replace node with appropriate child node
      node = find_matching_child_node(target, node)
      # if there's no match, throw an error
      node = Node.new(nil) unless node
    end
    node
  end

  def find_words node, words = []
    # Recurse through tree, print words if node.word is true
    words << node if node.word
    unless node.children.empty?
      node.children.each do |child|
        find_words(child, words)
      end
    end
    words
  end

  def print_words node
    # Recurse through tree, print words if node.word is true
    words = find_words(node)
    words.map{|node| node.value}.sort.join("\n")
  end

  def large_word_list
    File.read("/usr/share/dict/words")
  end

  def sort_nodes nodes, substr
    nodes.sort! do |a, b|
      if a.weight[substr] > 0 || b.weight[substr] > 0
        b.weight[substr] <=> a.weight[substr]
      else
        b.weight.values.reduce(0, :+) <=> a.weight.values.reduce(0, :+)
      end
    end
    nodes
  end

  def suggest substr, return_words = true
    node = find_node(substr)

    nodes = find_words(node)

    nodes = sort_nodes(nodes, substr)
    
    return_words ? nodes.map{|node| node.value} : nodes
  end

  def select substr, selection
    words = suggest substr, false
    # find index pos of selection
    pos = words.map{|node| node.value}.find_index(selection)
    # increment weight of word
    words[pos].weight[substr] += 1 if pos
    # move word to beginning of suggestions
    # words.insert(0, words.delete(pos))
    # return modified array
    words
  end

end

class Node

  attr_accessor :word, :children, :weight
  attr_reader :value

  def initialize value
    @value = value
    @word = false
    @children = []
    @weight = Hash.new(0)
  end

end

# dictionary = File.open("/usr/share/dict/words", "r").read

# trie = CompleteMe.new
# trie.populate(dictionary)
# puts trie.find_words(trie.dictionary).sample(500)
# binding.pry
# ""
