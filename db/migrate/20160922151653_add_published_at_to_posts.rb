class AddPublishedAtToPosts < ActiveRecord::Migration
  def change
    add_column :blogit_posts, :published_at, :datetime
  end
end
