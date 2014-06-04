class AddLog < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.datetime :created_at
      t.string :speaker_uid
      t.string :speaker_name
      t.integer :volume
      t.integer :original_volume
      t.string :original_state
      t.string :audio_uri
      t.decimal :duration
    end

    add_index :logs, :created_at
  end
end
