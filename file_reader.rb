require_relative 'sudoku'

module FileReader
  def self.from_file(path)
    initial = Array.new(9) { Array.new(9, 0) }

    File.open(path).each_with_index do |line, row|
      line.split(' ').each_with_index do |number, col|
        initial[row][col] = number.to_i
      end
    end

    Sudoku.new(initial)
  end
end
