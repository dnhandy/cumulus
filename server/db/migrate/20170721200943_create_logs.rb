class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.references :job, foreign_key: true
      t.text :contents
      t.string :application

      t.timestamps
    end
  end
end
