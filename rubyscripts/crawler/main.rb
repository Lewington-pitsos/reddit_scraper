require_relative 'interpreter.rb'
require_relative 'crawler.rb'
require_relative '../testing/eg_currency_mentions.rb'
require_relative '../testing/example_threads.rb'
=begin
puts "Mega start: #{Time.now}"

test_crawler = Crawler.new('https://www.reddit.com/r/CryptoCurrency/')

test_crawler.search_threads(4)

#test_interpreter.interpret_comment_all(test_crawler.stored_threads[0][:comments])
puts "end: #{Time.now}"

test_interpreter = CommentInterpreter.new()

test_crawler.stored_threads.each do |thread|
  test_interpreter.parse_thread(thread)
end

puts "interpretatio finiushed #{Time.now}"

puts test_crawler.stored_threads
=end

test_time = 'C:\Users\CustomPCs1000\xxx\projects\reddit\testing\rubyscripts\crawler\test_time.yaml'


File.open(test_time, 'w') do |file|
  file.write('')
end

crawler = ThreadCrawler.new('https://www.reddit.com/r/CryptoCurrency/new/', test_time)

crawler.parse_all_new_threads()

puts crawler.parsed_threads
