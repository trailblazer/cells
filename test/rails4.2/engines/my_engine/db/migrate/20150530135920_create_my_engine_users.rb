class CreateMyEngineUsers < ActiveRecord::Migration
  def change
    create_table :my_engine_users do |t|

      t.timestamps null: false
    end
  end
end
