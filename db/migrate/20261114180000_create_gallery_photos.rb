# frozen_string_literal: true

class CreateGalleryPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :gallery_photos do |t|
      t.references :season, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :caption, limit: 240
      t.timestamps
    end
    add_index :gallery_photos, [:season_id, :created_at]
  end
end
