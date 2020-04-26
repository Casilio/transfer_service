class CreateUserTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.column :name, :string
      t.column :balance, :decimal, precision: 16, default: 0
      t.timestamps
    end
  end
end
