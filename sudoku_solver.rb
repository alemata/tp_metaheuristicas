require_relative 'sudoku'

class SudokuSolver
  def initialize(sudoku)
    @sudoku = sudoku
    @size = sudoku.size
    @ants = 1
    @cycles = 1
  end

  def solve
    @b = nil
    @digit_row = Array.new(9) { Array.new(9, false) }
    @digit_column = Array.new(9) { Array.new(9, false) }

    g_max_selected = 0
    t = Array.new(9) { Array.new(9) { Array.new(9, 1000) } }
    @cycles.times do |cycle|
      max_selected = 0
      @ants.times do |ant|
        @b = Marshal.load(Marshal.dump(@sudoku.initial))
        @digit_row = Array.new(9) { Hash.new(false) }
        @digit_column = Array.new(9) { Hash.new(false) }
        places = Array.new(9) { Array.new(9) { Hash.new } }
        selected = 0
        can_select = true
        while can_select

          # Hanlde already selected
          @size.times do |row|
            @size.times do |col|
              digit = @b[row][col]
              if !digit.zero?
                @digit_row[row][digit] = true
                @digit_column[col][digit] = true
                selected += 1
              end
            end
          end

          @size.times do |row|
            @size.times do |col|
              (1..9).each do |digit|
                places[row][col][digit] = calculate_places(row, col, digit)
              end
            end
          end


          can_select = false
        end
      end
    end


    @sudoku
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
end
