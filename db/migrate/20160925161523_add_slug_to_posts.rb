class AddSlugToPosts < ActiveRecord::Migration
  def change
    add_column :blogit_posts, :slug, :string, uniq: true
  end
end
