class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :description
      t.boolean :display_in_navbar,default:false

      t.timestamps
    end
  end
end
