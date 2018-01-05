class TimeKeeper
  require 'yaml'
  attr_accessor :all_recorded, :path, :index

  def initialize(file_path)
    self.all_recorded = YAML.load_file(file_path) || []
    self.path = file_path
  end

  def validate_time(start, finish)
    # Ensures both times are given and that start is before finish
    # Ensures the span in question does not overlap any recorded spans
    # Sets the (chronlogical) index of this span among recorded spans
    self.check_chronology(start, finish)
    formatted_time = self.format(start, finish)
    self.index = find_place(formatted_time)
  end

  def keep(start, finish)
    # makes sure start is still earlier than finish
    # formats the given span
    # inserts it at the index found during validation
    # writes the modified time record to a file
    # NOTE: given span could be different from the one validated earlier, but since the only difference is a later start there is no possibility of new overlaps
    self.check_chronology(start, finish)
    formatted_time = self.format(start, finish)
    self.integrate(formatted_time, self.index)
    self.write
  end

  def find_place(time)
    # checks all the stored times (an array ordered by start time)
    # if one of them has a start AFTER the current time's start, returns true so long as the current time's finish is too
    # returns true by default
    self.all_recorded.each_with_index do |stored_time, index|
      if stored_time[:finish] > time[:start]
        if stored_time[:start] > time[:finish]
          return index
        else
          throw('Error: Timespan overlaps already recorded time')
        end
      end
    end
    return self.all_recorded.length
  end

  def integrate(time, index)
    if index
      self.all_recorded.insert(index, time)
    end
  end

  def format(start, finish)
    {start: start, finish: finish}
  end

  def get_time(index, symbol)
    # returns the latest time unless there are no times
    if self.all_recorded[index]
      self.all_recorded[index][symbol]
    else
      false
    end
  end

  def check_chronology(start, finish)
    unless start && finish && start < finish
      throw('Error: Invalid time entered')
    end
  end

  def get_latest_time
    self.get_time(-1, :finish)
  end

  def get_earliest_time
    self.get_time(0, :start)
  end

  def write
    File.open(self.path, 'w') do |file|
      file.write(self.all_recorded.to_yaml)
    end
  end
end
