class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.string :name
      t.integer :status, default: 0

      t.references :executable, references: :job_file
      t.references :state_file, references: :job_file

      t.timestamps
    end

    add_foreign_key :jobs, :job_files, column: :executable_id
    add_foreign_key :jobs, :job_files, column: :state_file_id
  end
end
