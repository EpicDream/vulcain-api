class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs, :force => true do |t|
      t.text :json
      t.timestamps
    end
  end

end