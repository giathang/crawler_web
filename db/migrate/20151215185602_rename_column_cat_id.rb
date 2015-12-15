class RenameColumnCatId < ActiveRecord::Migration
  def change
  	rename_column :posts, :cat_id, :category_id
  end
end
