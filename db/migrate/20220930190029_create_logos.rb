class CreateLogos < ActiveRecord::Migration[6.1]
  def change
    create_table :logos do |t|
      t.string :name
      t.string :file_path
      t.string :file_name
      t.string :file_type
      t.integer :unique_colors

      t.timestamps
    end
  end
end
