class Post < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings
  belongs_to :category

  define_index do
    indexes subject
    indexes content
    indexes tags.text, :as => :tags
    indexes comments.content, :as => :comments

    has comments(:id), :as => :comment_ids, :source => :ranged_query
    has category.name, :facet => true, :as => :category_name, :type => :string
  end
end
