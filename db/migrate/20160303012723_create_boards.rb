class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
    	t.string :board_array
      t.timestamps null: false
    end
  end
end
