class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.references :job, foreign_key: true
      t.integer :order
      t.text :contents

      t.timestamps
    end
  end
end
