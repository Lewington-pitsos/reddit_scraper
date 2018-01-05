# require_relative 'crawler.rb'

require_relative 'currencies.rb'
require_relative '../testing/example_thread.rb'
require_relative '../testing/eg_currency_mentions.rb'

class CommentInterpreter

  attr_accessor :current_comment, :comment_data, :all_comments
  # we match the data we want by matching the openeing and closing tags of the element that contains the data we want, and then reducing the result
  # all of these are assumptions about the way that reddit is currently set up
  # probably subject to hella change
  @@content = /(.+?)/

  @@author_opener = /<a[^>]+?class="author.+?>/
  @@author_closer = /<\/a>/
  @@author_matcher = /#{@@author_opener}#{@@content}#{@@author_closer}/

  @@score_opener = /<span[^>]+?class="score.+?>/
  @@score_closer = /<\/span>/
  @@score_matcher = /#{@@score_opener}#{@@content}#{@@score_closer}/

  @@comment_opener = '<p>'
  @@comment_closer = '<\/p>'
  @@comment_matcher = /#{@@comment_opener}#{@@content}#{@@comment_closer}/

  def initialize
    self.comment_data = {}
    self.all_comments = []
  end

  def mentions_currencies?(string)
    # records the string and searches it for currency mentions.
    # all currencies are recorded and if one or more is recorded we return truthy
    self.current_comment = string
    self.search_comment
    return self.comment_data[:currencies].length > 0
  end

  def get_comment_data
    self.get_author
    self.get_score
  end

  def interpret_comment_all(array)
    # wrapper, interprets every comment in an array
    array.each do |comment|
      self.interpret_comment(comment)
    end

  end

  def interpret_comment(comment)
    # first we check if any currencies are mentioned
    # => if so, we store all the comment's data and shove it to all_comments
    # =>  in either case we reset comment_data
    if self.mentions_currencies?(comment)
      self.get_comment_data
      self.all_comments << self.comment_data
    end
    self.comment_data = {}
  end

  def parse_thread(thread)
    # expects a comments object containing raw comment data,
    # parses all of the raw comments, and then replaces the raw data with the processed data
    comments = thread[:comments]
    self.interpret_comment_all(comments)
    thread[:comments] = self.all_comments
    self.all_comments = []
  end



  protected

  def get_currencies(formatted_comment)
    # creates an array containing all the currencies mentioned un the passed in chunk of text
    # no repeats, it picks up plurals and it ignores matches inside other words
    self.comment_data[:currencies] = []
    SAMPLE_NAMES.each do |currency|
      if formatted_comment.match(/\b#{currency}s?\b/i)
        name = NAME_ASSOCIATIONS[currency]
        unless self.comment_data[:currencies].include?(name)
          # we don't want to insert duplicates
          self.comment_data[:currencies] << name
        end
      end
    end
  end

  def search_comment
    # applies the comment regex to the present string and saves the result
    # result is reduced by scanning ALL paragraph matches, joining them and then simply removing the actual tags
    paragraphs = self.current_comment
      .scan(/<p>.+<\/p>/)
      .join()
      .gsub(/<\/?p>/, '')
    self.get_currencies(paragraphs)
    return paragraphs
  end

  def get_score
    # applies our score regex to the whole of the present string and saves the result
    # reduction is achieved by regex backwards referncing
    # changes the score to 0 if it was meant to be hidden
    score = self.current_comment[@@score_matcher, 1]
    if score == '[score hidden]' || !score
      score = '0'
    end
    self.comment_data[:score] = score.gsub(' points', '')
  end

  def get_author
    # applies the author regex to the present string and saves the result
    # reduction is achieved by regex backwards referncing
    author = self.current_comment[@@author_matcher, 1]
    self.comment_data[:user] = author
  end
end


class CurrencySniffer
  # gets passed in an array of objects and modifies each object by adding an array of its currency mentions to it
  attr_accessor :names, :conversions, :store

  def initialize
    self.names = ALL_CURRENCY_NAMES
    self.conversions = NAME_ASSOCIATIONS
    self.store = []
  end

  def get_all_currencies(array, text_key)
    # is given an array of objects and location in the object where its text is kept
    # adds a list of mentioned currencies mentioned in that text to that object,
    array.each do |object|
      object[:currencies] = self.get_currencies(object[text_key])
    end
  end

  def get_currencies(formatted_comment)
    # creates an array containing all the currencies mentioned un the passed in chunk of text
    # no repeats, it picks up plurals and it ignores matches inside other words
    currencies = []
    self.names.each do |currency|
      if formatted_comment.match(/\b#{currency}s?\b/i)
        name = self.conversions[currency]
        unless currencies.include?(name)
          # we don't want to insert duplicates
          currencies << name
        end
      end
    end

    currencies
  end
end
