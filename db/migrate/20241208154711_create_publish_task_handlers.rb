class CreatePublishTaskHandlers < ActiveRecord::Migration[8.0]
  def change
    create_table :publish_task_handlers do |t|
      t.string :marketplace, index: true
      t.integer :product_id, index: true
      t.json :steps
      t.integer :status
      t.json :logs

      t.timestamps
    end
  end
end
