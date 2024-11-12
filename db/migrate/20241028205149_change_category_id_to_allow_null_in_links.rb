class ChangeCategoryIdToAllowNullInLinks < ActiveRecord::Migration[6.0]
  def change
    change_column_null :links, :category_id, true
  end
end
