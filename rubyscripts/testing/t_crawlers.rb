require "minitest/autorun"
require 'time'
require 'yaml'
require_relative '../crawler/crawler.rb'
require_relative 'example_comments.rb'
require_relative '../testing/example_threads.rb'

class ThreadCrawlerTest < Minitest::Test
  def setup
    @saved_time = YAML.load_file(TIME_FILE_PATH)
    @crawler = ThreadCrawler.new('https://www.reddit.com/r/CryptoCurrency/new/')
  end

  def test_stores_time_properly
    placeholder_time = Time.now()
    @crawler.send(:store_time, placeholder_time)
    recovered_time = YAML.load_file(TIME_FILE_PATH)
    assert_equal(placeholder_time, recovered_time)
  end

  def test_recovers_time_properly
    placeholder_time = Time.now()
    @crawler.send(:store_time, placeholder_time)
    recovered_time = @crawler.send(:take_time)
    assert_equal(placeholder_time, recovered_time)
  end

  def test_sets_time_properly
    placeholder_time = Time.now()
    @crawler.send(:store_time, placeholder_time)
    new_crawler = ThreadCrawler.new('some_website')
    assert_equal(new_crawler.earliest, placeholder_time)
  end

  def teardown
    File.open(TIME_FILE_PATH, 'w') do |file|
      file.write(@saved_time.to_yaml)
    end
  end
end
