class CreateFlights < ActiveRecord::Migration[7.0]
  def change
    create_table :flights do |t|
      t.timestamps
      t.string :origin
      t.string :destination
      t.date :date
      t.integer :price
      t.string :airline
    end
  end
end
