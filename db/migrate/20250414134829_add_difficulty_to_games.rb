class AddDifficultyToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :difficulty, :string
  end
end
