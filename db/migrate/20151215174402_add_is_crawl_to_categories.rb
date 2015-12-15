class AddIsCrawlToCategories < ActiveRecord::Migration
  def change
  	add_column :categories,:is_crawl,:string
  end
end
