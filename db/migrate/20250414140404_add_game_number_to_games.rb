class AddGameNumberToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :game_number, :integer
  end
end
