class AddPosterizationLevelToLogos < ActiveRecord::Migration[6.1]
  def change
    add_column :logos, :posterization_level, :integer
  end
end
