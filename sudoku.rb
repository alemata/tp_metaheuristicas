require_relative 'file_reader'

class Sudoku
  attr_reader :initial, :size,
              :places, :b, :digit_row, :digit_column,
              :digits, :digit_to_add,
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
    @digits = Array.new(9) { Array.new(9, 0) }
    @digit_to_add = Array.new(9) { Array.new(9) }
    @selected = 0
  end

  def can_put_any_number?
    digit_in_one_position = @places.any? do |row|
      row.any? do
        |col| col.values.any?{|d| d == 1}
      end
    end

    position_with_one_digit = @digits.flatten.include?(1)

    digit_in_one_position || position_with_one_digit
  end

  # Update how many digits can be entered
  # in each position
  def update_digit_amounts_in_positions
    @size.times do |row|
      @size.times do |col|
        digits_amount = 0
        digit_to_add = 0
        (1..9).each do |digit|
          if(@b[row][col].zero? && !@digit_row[row][digit] && !@digit_column[col][digit])
            digits_amount += 1
            digit_to_add = digit
          end
        end
        @digits[row][col] = digits_amount
        @digit_to_add[row][col] = digit_to_add if digits_amount == 1
      end
    end
  end

  # Update how many digits can be entered
  # in each position
  def fill_position_with_only_one_posible_digit
    @size.times do |row|
      @size.times do |col|
        if @digits[row][col] == 1
          if(can_add_digit(row, col, @digit_to_add[row][col]))
            add_digit(row, col, @digit_to_add[row][col])
          end
        end
      end
    end
  end

  def add_digits_with_only_one_posible_position
    @size.times do |row|
      @size.times do |col|
        (1..9).each do |digit|
          positions = @places[row][col][digit]
          if (positions == 1)
            place_to_add = get_place_to_add(row, col, digit)
            add_row = place_to_add[:row]
            add_col = place_to_add[:col]
            if(can_add_digit(add_row, add_col, digit))
              add_digit(add_row, add_col, digit)
            end
          end
        end
      end
    end
  end

  def add_digit(row, col, digit)
    if(!can_add_digit(row, col, digit))
      puts self
      puts "row: #{row}, col: #{col}, digit:#{digit}"
      raise "Trying to insert a wrong number."
    end
    puts "inserted => row: #{row}, col: #{col}, digit: #{digit}"
    @b[row][col] = digit
    @digit_row[row][digit] = true
    @digit_column[col][digit] = true
    @selected += 1
    update_places
  end

  def can_add_digit(row, col, digit)
    (@b[row][col].zero? && !@digit_row[row][digit] &&
     !@digit_column[col][digit] && !included_in_submatrix(row, col, digit))
  end

  def get_place_to_add(row, col, digit)
    start_row = (row / 3) * 3;
    start_col = (col / 3) * 3;
    (start_row..start_row + 2).each do |r|
      (start_col..start_col + 2).each do |c|
        if(@b[r][c].zero? && !@digit_row[r][digit] && !@digit_column[c][digit])
          return {row: r, col: c}
        end
      end
    end

    # Return invalid position when no place to add found
    return nil
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

  # Update the numbers of places a digit can be entered
  # in each submatrix
  def update_places
    @size.times do |row|
      @size.times do |col|
        (1..9).each do |digit|
          @places[row][col][digit] = calculate_places(row, col, digit)
        end
      end
    end
  end

  # Get number of places each digit can be entered
  # inside the submatrix inside row, col
  def calculate_places(row, col, digit)
    res = 0
    start_row = (row / 3) * 3;
    start_col = (col / 3) * 3;
    if(!included_in_submatrix(row, col, digit))
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


  # Check if a digit is included in a submatix
  def included_in_submatrix(row, col, digit)
    start_row = (row / 3) * 3;
    start_col = (col / 3) * 3;

    res = false;
    (start_row..start_row + 2).each do |row|
      (start_col..start_col + 2).each do |col|
        res ||= (@b[row][col] == digit)
      end
    end

    res
  end

  def get_next_to_fill(p_array, p_matrix)
    can_be_added = []
    9.times do |row|
      9.times do |col|
        (1..9).each do |digit|
          if (can_add_digit(row, col, digit))
            can_be_added << {row: row, col: col, digit: digit, p: p_matrix[row][col][digit]}
          end
        end
      end
    end
    sorted = can_be_added.sort_by{|can_be_add| can_be_add[:p]}.reverse
    percent = sorted.count * 20 / 100
    to_add = sorted[0..percent].sample
  end

  def can_be_added
    can_be_added = []
    9.times do |row|
      9.times do |col|
        (1..9).each do |digit|
          if (can_add_digit(row, col, digit))
            can_be_added << {row: row, col: col, digit: digit}
          end
        end
      end
    end
    can_be_added
  end

  def solved?
    rows_ok = b.all?{ |row| row.uniq.count == 9 }
    cols = b.transpose
    cols_ok = cols.all?{ |row| row.uniq.count == 9 }

    rows_ok && cols_ok
  end

  # TODO improve
  def valid?
    rows_digit_ok = check_repetition(b)
    cols_digit_ok = check_repetition(b.transpose)

    rows_digit_ok && cols_digit_ok
  end

  def check_repetition(array)
    rows_digit_count = array.map do |row|
      row.each_with_object(Hash.new(0)){ |digit, counts| counts[digit] += 1 }
    end
    rows_digit_count.map{ |counts| counts.delete(0) }
    rows_ok = rows_digit_count.all?{ |counts| counts.values.uniq == [1] }
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
    str << "\n"
    str << "Result \n"
    @size.times do |row|
      @size.times do |col|
        str << "#{@b[row][col]} "
        str << "| " if col == 2 || col == 5
      end
      str << "\n"
      str << "-" * 21 + "\n" if row == 2 || row == 5
    end

    puts str
  end
end
