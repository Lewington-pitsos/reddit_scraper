require "minitest/autorun"
require 'yaml'
require 'time'
require_relative '../crawler/timekeeper.rb'

EXAMPLE_TIME_DATA = [{start: Time.parse('2017-9-21 23:36:17.978039000 +11:00'), finish: Time.parse('2017-9-22 01:37:39.293234000 +11:00') },
{start: Time.parse('2017-10-21 23:36:17.978039000 +11:00'), finish: Time.parse('2017-10-22 01:37:39.293234000 +11:00') },
{start: Time.parse('2017-10-28 23:36:17.978039000 +11:00'), finish: Time.parse('2017-10-29 01:37:39.293234000 +11:00') }]
FILE_PATH = './rubyscripts/testing/time_data'

class ArchivistTest < Minitest::Test

  def setup
    File.open(FILE_PATH, 'w') do |file|
      file.write(EXAMPLE_TIME_DATA.to_yaml)
    end
    @keeper = TimeKeeper.new(FILE_PATH)

  end

  def test_loads_file
    assert_equal(EXAMPLE_TIME_DATA, @keeper.all_recorded)
  end

  def test_adds_new_valid_time_entity
    start = Time.parse('2017-10-30 01:37:39.293234000 +11:00')
    finish = Time.parse('2017-10-30 09:37:39.293234000 +11:00')
    @keeper.keep(start, finish)
    dummy_record = EXAMPLE_TIME_DATA.clone
    dummy_record << {start: start, finish: finish}
    assert_equal(@keeper.all_recorded, dummy_record)
  end

  def test_finds_used_times
    # after all times
    start = Time.parse('2017-11-30 01:37:39.293234000 +11:00')
    finish = Time.parse('2017-11-30 09:37:39.293234000 +11:00')
    result = @keeper.find_place({start: start, finish: finish})
    assert_equal(3, result)
    # before all times
    start = Time.parse('2017-6-2 01:37:39.293234000 +11:00')
    finish = Time.parse('2017-6-2 09:37:39.293234000 +11:00')
    result = @keeper.find_place({start: start, finish: finish})
    assert_equal(0, result)
    # overlapping multiple times
    start = Time.parse('2017-10-28 01:37:39.293234000 +11:00')
    finish = Time.parse('2017-10-30 09:37:39.293234000 +11:00')
    assert_raises 'Error: Timespan overlaps already recorded time' do
      @keeper.find_place({start: start, finish: finish})
    end
    # within one time
    start = Time.parse('2017-10-28 23:40:17.978039000 +11:00')
    finish = Time.parse('2017-10-28 23:51:17.978039000 +11:00')
    assert_raises 'Error: Timespan overlaps already recorded time' do
      @keeper.find_place({start: start, finish: finish})
    end
    # starts within one time ends afterit
    start = Time.parse('2017-10-28 23:40:17.978039000 +11:00')
    finish = Time.parse('2017-10-29 23:51:17.978039000 +11:00')
    assert_raises 'Error: Timespan overlaps already recorded time' do
      @keeper.find_place({start: start, finish: finish})
    end
    # starts before one time ends inside it
    start = Time.parse('2017-10-27 23:40:17.978039000 +11:00')
    finish = Time.parse('2017-10-28 23:51:17.978039000 +11:00')
    assert_raises 'Error: Timespan overlaps already recorded time' do
      @keeper.find_place({start: start, finish: finish})
    end
  end

  def test_rejects_used_times
    start = Time.parse('2017-10-27 23:40:17.978039000 +11:00')
    finish = Time.parse('2017-10-28 23:51:17.978039000 +11:00')
    assert_raises 'Error: Timespan overlaps already recorded time' do
      @keeper.keep(start, finish)
    end
  end

  def test_badly_ordered_times
    finish = Time.parse('2017-11-30 01:37:39.293234000 +11:00')
    start = Time.parse('2017-11-30 09:37:39.293234000 +11:00')
    assert_raises 'Error: Invalid time entered' do
      @keeper.keep(start, finish)
    end
  end

  def test_inserts_in_order
    # in the middle
    start = Time.parse('2017-9-23 23:36:17.978039000 +11:00')
    finish = Time.parse('2017-9-25 01:37:39.293234000 +11:00')
    @keeper.keep(start, finish)
    dummy_record = EXAMPLE_TIME_DATA.clone
    dummy_record.insert(1, {start: start, finish: finish})
    assert_equal(dummy_record, @keeper.all_recorded)
  end

  def test_returns_latest_time
    assert_equal(Time.parse('2017-10-29 01:37:39.293234000 +11:00'), @keeper.get_latest_time)
  end

  def test_returns_earliest_time
    assert_equal(Time.parse('2017-9-21 23:36:17.978039000 +11:00'), @keeper.get_earliest_time)
  end

  def test_returns_false_if_no_times
    @keeper.all_recorded = []
    assert_equal(false, @keeper.get_earliest_time)
    assert_equal(false, @keeper.get_latest_time)
  end

  def test_writes_to_file
    start = Time.parse('2017-10-28 23:40:17.978039000 +11:00')
    finish = Time.parse('2017-10-29 23:51:17.978039000 +11:00')
    time = {start: start, finish: finish}
    @keeper.all_recorded = time
    @keeper.write
    results = YAML.load_file(FILE_PATH)
    assert_equal(time, results)
  end

  def test_copes_with_empty_path
    File.open(FILE_PATH, 'w') do |file|
      file.write('')
    end
    new_keeper = TimeKeeper.new(FILE_PATH)
    start = Time.parse('2017-10-28 23:40:17.978039000 +11:00')
    finish = Time.parse('2017-10-29 23:51:17.978039000 +11:00')
    new_keeper.keep(start, finish)
    assert_equal([{start: start, finish: finish}], new_keeper.all_recorded)
  end

  def teardown
    FileUtils.rm(FILE_PATH)
  end
end
