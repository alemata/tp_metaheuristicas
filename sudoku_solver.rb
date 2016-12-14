require_relative 'sudoku'

class SudokuSolver
  def initialize(sudoku)
    @sudoku = sudoku
    @size = sudoku.size
    @ants = 1
    @cycles = 1
  end

  def solve
    g_max_selected = 0
    t = Array.new(9) { Array.new(9) { Array.new(9, 1000) } }
    @cycles.times do |cycle|
      max_selected = 0
      @ants.times do |ant|
        ant_sudoku = Sudoku.new(@sudoku.initial)
        can_select = true
        while can_select
          ant_sudoku.update_selected
          ant_sudoku.update_places
          ant_sudoku.add_digits_with_only_one_posible_position

          can_select = false
        end
      end
    end


    @sudoku
  end

end
