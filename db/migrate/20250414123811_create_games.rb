class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :board
      t.string :current_player
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
