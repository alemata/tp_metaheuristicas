require_relative 'sudoku'

class SudokuSolver
  def initialize(sudoku)
    @sudoku = sudoku
    @size = sudoku.size
    @ants = 5
    @cycles = 20
  end

  def solve
    g_max_selected = 0
    final_sudoku = nil
    evaporation = 0.99
    t = Array.new(9) { Array.new(9) { Hash.new(1000) } }
    p = Array.new(9) { Array.new(9) { Hash.new } }
    w = Array.new(9) { Array.new(9) { Hash.new } }
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

          counter = 0 # Have an issue here that sometimes is't stuck
          while ant_sudoku.can_put_any_number? && counter < 729
            ant_sudoku.add_digits_with_only_one_posible_position
            ant_sudoku.update_digit_amounts_in_positions
            ant_sudoku.fill_position_with_only_one_posible_digit

            ant_sudoku.update_places
            ant_sudoku.update_digit_amounts_in_positions
            counter += 1
          end

          #Update tmp variables to calculate probability
          sumw = 0
          9.times do |row|
            9.times do |col|
              (1..9).each do |digit|
                # Si places[row][col][digit] no tendria que dar 0 la probabilidad?
                nij = (10 - ant_sudoku.places[row][col][digit]) * (10 - ant_sudoku.digits[row][col])
                w[row][col][digit] = t[row][col][digit] * nij
                sumw += w[row][col][digit]
              end
            end
          end

          #Update probability
          p_array = []
          9.times do |row|
            9.times do |col|
              (1..9).each do |digit|
                probability = w[row][col][digit].to_f / sumw
                p[row][col][digit] = probability
                p_array << probability
              end
            end
          end

          next_to_fill = ant_sudoku.get_next_to_fill(p_array, p)
          if next_to_fill
            ant_sudoku.add_digit(next_to_fill[:row], next_to_fill[:col], next_to_fill[:digit])
          end

          can_select = ant_sudoku.selected < 81
          can_select = can_select && !(ant_sudoku.can_be_added.size.zero?)
          puts can_select
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
      9.times do |row|
        9.times do |col|
          (1..9).each do |digit|
            t[row][col][digit] *= evaporation
          end
        end
      end

      dt = max_selected / 81.0;
      9.times do |row|
        9.times do |col|
          (1..9).each do |digit|
            used_digit = max_sudoku.b[row][col]
            if (used_digit != 0)
              t[row][col][digit] += dt;
            end
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
