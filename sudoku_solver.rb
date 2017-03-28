require_relative 'sudoku'

class SudokuSolver

  SIZE = 9

  def initialize(sudoku, cycles = 20, ants = 4, evaporation = 0.99)
    @sudoku = sudoku
    @cycles = cycles
    @ants = ants
    @evaporation = evaporation
  end

  def solve
    g_max_selected = 0
    final_sudoku = nil
    t = Array.new(SIZE) { Array.new(SIZE) { Hash.new(1000) } }
    p = Array.new(SIZE) { Array.new(SIZE) { Hash.new } }
    w = Array.new(SIZE) { Array.new(SIZE) { Hash.new } }
    @cycles.times do |cycle|
      puts "cycle: #{cycle}"
      max_selected = 0
      max_sudoku = nil
      @ants.times do |ant|
        puts "ant: #{ant}"
        ant_sudoku = Sudoku.new(@sudoku.initial)
        ant_sudoku.update_selected
        can_select = true
        while can_select
          ant_sudoku.update_places

          ant_sudoku.add_all_possible_initial_values

          #Update tmp variables to calculate probability
          sumw = 0
          SIZE.times do |row|
            SIZE.times do |col|
              (1..SIZE).each do |digit|
                # Si places[row][col][digit] no tendria que dar 0 la probabilidad?
                # nij = ant_sudoku.places[row][col][digit] == 0 ? 0 : (10 - ant_sudoku.places[row][col][digit]) * (10 - ant_sudoku.digits[row][col])
                nij = (10 - ant_sudoku.places[row][col][digit]) * (10 - ant_sudoku.digits[row][col])
                w[row][col][digit] = t[row][col][digit] * nij
                sumw += w[row][col][digit]
              end
            end
          end

          #Update probability
          SIZE.times do |row|
            SIZE.times do |col|
              (1..SIZE).each do |digit|
                probability = w[row][col][digit].to_f / sumw
                p[row][col][digit] = probability
              end
            end
          end

          next_to_fill = ant_sudoku.get_next_to_fill(p)
          if next_to_fill
            ant_sudoku.add_digit(next_to_fill[:row], next_to_fill[:col], next_to_fill[:digit])
          end

          can_select = ant_sudoku.selected < 81
          can_select = can_select && !(ant_sudoku.can_be_added.size.zero?)
        end

        # End of ant
        if ((ant_sudoku.selected > max_selected) || max_selected == 0)
          max_selected = ant_sudoku.selected
          max_sudoku = ant_sudoku
        end

        # Break if already found the solution
        break if ant_sudoku.selected == 81
      end

      # End of all ants
      SIZE.times do |row|
        SIZE.times do |col|
          (1..SIZE).each do |digit|
            t[row][col][digit] *= @evaporation
          end
        end
      end

      dt = max_selected / 81.0;
      SIZE.times do |row|
        SIZE.times do |col|
          used_digit = max_sudoku.b[row][col]
          if (used_digit != 0)
            t[row][col][used_digit] += dt;
          end
        end
      end

      if (max_selected > g_max_selected)
        g_max_selected = max_selected;
        final_sudoku = max_sudoku;
      end

      break if g_max_selected == 81
    end

    final_sudoku
  end
end
