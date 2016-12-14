require_relative 'file_reader'

class Sudoku
  def self.from_file(file_name)
    FileReader.from_file(file_name)
  end

  def initialize(initial)
    @initial = initial
    @size = 9
  end

  def inspect
    str = ""
    (0..@size-1).each do |row|
      (0..@size-1).each do |col|
        str << "#{@initial[row][col].inspect} "
        str << "| " if col == 2 || col == 5
      end
      str << "\n"
      str << "-" * 21 + "\n" if row == 2 || row == 5
    end
    str
  end

  def to_s
    inspect
  end
end
