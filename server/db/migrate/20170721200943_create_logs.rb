class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.references :executable, foreign_key: true
      t.references :state_file, foreign_key: true
      t.integer :order
      t.text :contents

      t.timestamps
    end
  end
end
