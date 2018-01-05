require_relative 'crawler/interpreter.rb'
require_relative 'crawler/crawler.rb'
require_relative 'archive/archivist.rb'
require_relative 'archive/librarian.rb'
require_relative 'testing/eg_currency_mentions.rb'
require_relative 'testing/example_threads.rb'

def scrape
  crawler = ThreadCrawler.new('https://www.reddit.com/r/CryptoCurrency/new/')
  archivist = Archivist.new('currencies')

  crawler.parse_all_new_threads()

  puts crawler.parsed_threads

  archivist.store_all_mentions(crawler.parsed_threads)
end

def view_archive
  librarian = Librarian.new('currencies')
  librarian.print_table('users')
end


start = Time.now
scrape()
view_archive()
puts "Total Time Taken in Minutes: #{(Time.now - start) / 60}"
