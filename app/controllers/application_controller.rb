class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :complete, :gen_board, :grand_filter


  # Depth-first Backtrack Search Algorithm
  def complete
    #81 times for each block in the puzzle
    @board.each do |key, value|
      next if value != 0

      candidatesArray = grand_filter(key)

      candidatesArray.each  do |possibility|
           @board[key] = possibility
           foundAll = complete
           if(foundAll == true)
             return true
           end
      end

      # finished trying all the candidates, backtrack
      @board[key] = 0
      return false
    end

    return true
  end



#gen board needs to create a hash with key represented as column (A)/row (0) intersections ("A0") and values as board_array (1..9 or -)
  def gen_board
  	board = {}
    ("A".."I").each do |row|
      (0..8).each_with_index { |column, value| board.merge!( { "#{row}#{column}".to_sym => @board_array.shift.to_i } ) }
    end
    return board
  end


    def get_master_cell(initial_cell)
	    starting_point = initial_cell.to_sym
	    master_cell = { }
	    letter = initial_cell[0]
	    number = initial_cell[1]
	    a_symbol = nil

	    3.times do
        3.times do
          a_symbol = ( letter + number ).to_sym
          master_cell.merge!( { a_symbol => @board[ a_symbol ] } )
          number.next!
        end
        letter.next!
        number = initial_cell[1]
      end
      return master_cell
  end

  def gen_master_cell_list
    initial_cell = ["A0", "A3", "A6", "D0", "D3", "D6", "G0", "G3", "G6"]

    initial_cell.each do |cell|
      @master_cell_list.merge!({cell.to_sym => get_master_cell(cell)})
    end
    return @master_cell_list
  end

  def get_value(key)
    @board[key.to_sym]
  end

  def set_value(key, value)
    @board[key.to_sym] = value
  end

  def filter_row(key)
    column_label = key[0]
    row = get_row(column_label)

    return @possible_values.select{ |value| not row.include?(value) }
  end

  def filter_column(key)
    row_label = key[1]
    column = get_column(row_label)

    return @possible_values.select{ |value| not column.include?(value) }
  end


  #new method with get_master_cell and only call it with the initial values of each master cell
  # the key can be the very first cell and the values can be all of the cells in that master cell



  def get_row(column_label)
    row = []

    (0..8).each do |row_label|
      row << get_value( column_label + row_label.to_s )
    end
    return row
  end

  def get_column(row_label)
    column = []

    ("A".."I").each do |column_label|
      column << get_value( column_label + row_label.to_s )
    end
    return column
  end

#returns a hash that represents the master cell the cell_to_match is in
  def find_master(cell_to_match)
    gen_master_cell_list
    @master_cell_list.each do |cell, value|
       value.each_key do |key|
           return value if key == cell_to_match.to_sym
       end
    end
  end


  def filter_master_cell(key)
    master_cell = find_master(key)
    master_values = []
    master_cell.each_value do |value|
      master_values << value
    end
    #compare @possible_values with the values in that master_cell
    return @possible_values.select{ |value| not master_values.include?(value) }
  end

  def grand_filter(key)
    ( filter_row(key) & filter_column(key) ) & filter_master_cell(key)
  end

end
