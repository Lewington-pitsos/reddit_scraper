require "minitest/autorun"
require_relative '../archive/archivist.rb'
require_relative 'eg_parsed_thread_data.rb'
class ArchivistTest < Minitest::Test

  def setup
    @archivist = Archivist.new()
  end

  def method_name

  end

  def teardown
  end
end
