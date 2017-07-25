class CreateJobFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :job_files do |t|
      t.string :name
      t.binary :contents

      t.timestamps
    end
  end
end
