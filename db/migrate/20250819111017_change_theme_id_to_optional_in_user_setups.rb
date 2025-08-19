class ChangeThemeIdToOptionalInUserSetups < ActiveRecord::Migration[8.0]
  def change
    change_column_null :user_setups, :theme_id, true
  end
end
