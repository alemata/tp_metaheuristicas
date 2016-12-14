require_relative 'file_reader'

class Sudoku
  attr_reader :initial, :size

  def self.from_file(file_name)
    FileReader.from_file(file_name)
  end

  def initialize(initial)
    @initial = initial
    @size = 9
  end

  def to_s
    str = ""
    @size.times do |row|
      @size.times do |col|
        str << "#{@initial[row][col]} "
        str << "| " if col == 2 || col == 5
      end
      str << "\n"
      str << "-" * 21 + "\n" if row == 2 || row == 5
    end
    puts str
  end
end
