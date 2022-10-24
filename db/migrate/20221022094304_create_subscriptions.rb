class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.string :origin
      t.string :destination
      t.date :date_start
      t.date :date_end
      t.integer :lowest_price
      t.integer :opposite_flight_id

      t.timestamps
    end
  end
end
