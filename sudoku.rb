require_relative 'file_reader'

class Sudoku
  attr_reader :initial, :size,
              :places, :b, :digit_row, :digit_column,
              :selected

  def self.from_file(file_name)
    FileReader.from_file(file_name)
  end

  def initialize(initial)
    @initial = initial
    @size = 9
    @b = Marshal.load(Marshal.dump(initial))
    @digit_row = Array.new(9) { Hash.new(false) }
    @digit_column = Array.new(9) { Hash.new(false) }
    @places = Array.new(9) { Array.new(9) { Hash.new } }
    @selected = 0
  end

  # Hanlde already selected
  def update_selected
    @size.times do |row|
      @size.times do |col|
        digit = @b[row][col]
        if !digit.zero?
          @digit_row[row][digit] = true
          @digit_column[col][digit] = true
          @selected += 1
        end
      end
    end
  end

  def update_places
    @size.times do |row|
      @size.times do |col|
        (1..9).each do |digit|
          @places[row][col][digit] = calculate_places(row, col, digit)
        end
      end
    end
  end

  def calculate_places(row, col, digit)
    res = 0
    start_row = (row / 3) * 3;
    start_col = (col / 3) * 3;
    if(!included_in_submatrix(start_row, start_col, digit))
      (start_row..start_row + 2).each do |r|
        (start_col..start_col + 2).each do |c|
          if(@b[r][c].zero? && !@digit_row[r][digit] && !@digit_column[c][digit])
            res += 1
          end
        end
      end
    end

    res
  end

  def included_in_submatrix(start_row, start_col, digit)
    res = false;
    (start_row..start_row + 2).each do |row|
      (start_col..start_col + 2).each do |col|
        res ||= (@b[row][col] == digit)
      end
    end

    res
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
