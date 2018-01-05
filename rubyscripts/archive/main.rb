require_relative 'librarian.rb'
require_relative 'archivist.rb'
require_relative 'data_god.rb'
require_relative '../testing/eg_parsed_threads.rb'

god = DataGod.new('testdb');

god.teardown_database()

god.setup_database()

joe = Archivist.new('testdb')

EG_PARSED_THREADS.each do |mention|
  joe.archive_mention(mention)
end

# joe.insert('comments', 'name', 'PLACEHOLDER')

# joe.delete_matches('comments', false, 'PLACEHOLDER')


lin = Librarian.new('testdb')

lin.show_all_tables

lin.print_table('mentions')
