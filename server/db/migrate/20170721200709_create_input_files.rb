class CreateInputFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :input_files do |t|
      t.references :job, foreign_key: true
      t.references :job_file, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
