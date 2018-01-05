require 'capybara'
require 'capybara/poltergeist'
require 'time'
require 'yaml'
require_relative 'interpreter.rb'
require_relative 'timekeeper.rb'
Capybara.register_driver(:poltergeist) { |app| Capybara::Poltergeist::Driver.new(app, js_errors: false) }
Capybara.javascript_driver = :poltergeist
Capybara.default_driver = :poltergeist

TIME_FILE_PATH = './rubyscripts/crawler/time.yaml'

class ThreadCrawler
  attr_accessor :all_threads, :parsed_threads, :session, :finished, :finish, :start, :page, :sniffer, :time_keeper, :clicks
  @@thread_identifier = '.entry.unvoted'
  # this selector gives us an advert as well as the first entry, but I don't know how to avoid it
  @@tag_identifier = '.linkflairlabel'
  @@title_identifier = 'a.title'
  @@time_identifier = 'time'
  @@comments_identifier = '.first a'
  @@button_identifier = '.next-button'
  @@user_identifier = 'a.author'

  def initialize(page, time_file_path=TIME_FILE_PATH)
    self.finished = false
    self.session = Capybara.current_session
    self.page = page
    self.parsed_threads = []
    self.sniffer = CurrencySniffer.new()

    self.time_keeper = TimeKeeper.new(time_file_path)
    # the earliest/latest times that this object will ever scrape. These can be manually set by passing in a times hash
  end

  def parse_all_new_threads(times = {})
    # receives a time object representing the timespan we should look for threads over
    # visits the frontpage
    # generates default times if none are supplied and validates them either way
    # and starts storing every thread (after the specified latest time) untill we reach one whose time is before the specified earliest time
    # sniffs each stored thread for currencies
    # => stores the seacrhed timespan upon success
    self.clicks = 0
    self.clear_records
    self.session.visit(self.page)

    self.finish = times[:finish] || self.default_time
    self.start = times[:start] || self.latest_recorded_time
    self.time_keeper.validate_time(self.start, self.finish)

    while !self.finished
    # finished is switchesd to true as soon as we hit a thread that has already been parsed OR we reach 39 pages
      self.parse_page
      self.try_next_page
    end

    self.sniffer.get_all_currencies(self.parsed_threads, :title)

    self.time_keeper.keep(self.start, self.finish)
    self.finished = false
  end

  protected

  def parse_thread(thread)
    # finds and returns the information of a single thread
    data = {}

    data[:tag] = 'N/A'
    if thread.has_css?(@@tag_identifier)
      # sometimes there ius no tag and an error is thrown if the find method can't find any matches
      data[:tag] = thread.find(@@tag_identifier).text
    end

    if thread.has_css?(@@user_identifier)
      data[:user] = thread.find(@@user_identifier).text
    elsif
      puts "-----ERROR THREAD---------#{thread}"
      data[:user] = 'ERROR'
    end

    data[:title] = thread.find(@@title_identifier).text
    data[:comments] = thread.find(@@comments_identifier).text
    data[:source] = 'reddit'
    return data
  end

  def try_next_page
    # finds the "next page" button, clicks it, and records the click
    # if we are on page 39, there is no next page button, so we phone it in
    if self.clicks < 38
      self.go_next_page
    else
      self.start_here
    end
  end

  def go_next_page
    self.clicks += 1
    puts URI.parse(self.session.current_url)
    # in case of an error we can visit the offending page
    self.session.first(@@button_identifier).click()
  end

  def start_here
    # print a warning
    # change start time for this scrape to the last time recorded on this page
    # forces scaping to cease
    puts "WARNING: max stored threads reached before target start time"
    self.start = self.parsed_threads[-1][:time]
    self.finished = true
  end

  def parse_page
    # grabs and stores the data of all threads on the page
    # avoids parsing the first thread with 'count' (it's an advert)
    # avoids storing all early threads
    # halts the runthrough if we encounter an already-stored thread
    count = 0
    self.find_threads
    self.all_threads.each do |thread|
      if count > 0
        # the first entry is always an advert
        current_time = self.get_thread_time(thread)
        if current_time < self.finish
          # gives us the option of having a late cutoff
          if current_time < self.start
          # we want to avoid parsing already parsed threads, so we end each runthrough as soon as we find a thread that's older than our cutoff
            self.finished = true
            break
          else
            current_data = self.parse_thread(thread)
            current_data[:time] = current_time
            self.parsed_threads << current_data
          end
        end
      end
      count = 1
    end
  end

  def get_thread_time(thread)
    Time.parse(thread.all(@@time_identifier)[0][:title])
  end

  def latest_recorded_time()
    # returns the array which represents the current time store
    recovered_time = self.time_keeper.get_latest_time
    recovered_time || self.default_time() - (60 * 60 * 2)
  end

  def clear_records
    self.parsed_threads = []
  end

  def reddit_time
    Time.now - (60 * 60 * 11);
    # It looks like reddit's time is 11 hours behind ours
  end

  def default_time
    self.reddit_time - (60 * 60 * 2)
    # we want to collect threads after a day so they have time to acucmulate comments (2 hours for now)
  end

  def find_threads
    self.all_threads = self.session.all(@@thread_identifier);
  end
end
