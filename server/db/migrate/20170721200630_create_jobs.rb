class CreateJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :jobs do |t|
      t.string :status
      t.references :job_file, foreign_key: true

      t.timestamps
    end
  end
end
