module Blogit
  class Post < ActiveRecord::Base
    
    require "kaminari"
    require "acts-as-taggable-on"
    require "acts_as_commentable_with_threading"

    acts_as_taggable
    acts_as_commentable

    self.paginates_per(Blogit.configuration.posts_per_page)

    # ===============
    # = Validations =
    # ===============

    validates :title, presence: true, length: { minimum: 10 }

    validates :body,  presence: true, length: { minimum: 10 }
    
    validates :description, presence: Blogit.configuration.show_post_description

    validates :blogger, presence: true

    validates :state, presence: true

    # ================
    # = Associations =
    # ================

    ##
    # The blogger (User, Admin, etc.) who wrote this Post
    #
    # Returns a Blogger (polymorphic type)
    belongs_to :blogger, :polymorphic => true

    ##
    # The {Comment Comments} written on this Post
    #
    # Returns an ActiveRecord::Relation instance
    
    has_many :comments, ->{ where(parent_id: nil) }, class_name: 'Comment',
      as: :commentable, inverse_of: :commentable

    # ==========
    # = Scopes =
    # ==========

    scope :for_index, lambda { |page_no = 1| 
      active.order("published_at DESC").page(page_no) }
      
    scope :active, lambda { where(state:  Blogit.configuration.active_states ) }

    before_save :set_published_at, if: ->{ published_at.blank? }
    before_save :set_slug, if: ->{ slug.blank? }


    # The posts to be displayed for RSS and XML feeds/sitemaps
    #
    # Returns an ActiveRecord::Relation
    def self.for_feed
      active.order('published_at DESC')
    end
    
    # Finds an active post with given id
    #
    # id - The id of the Post to find
    #
    # Returns a Blogit::Post
    # Raises ActiveRecord::NoMethodError if no Blogit::Post could be found
    def self.active_with_id(id)
      active.find_by('slug = ? or id = ?', id, id.to_i)
    end
    
    # ====================
    # = Instance Methods =
    # ====================

    def next_post
      self.class.for_feed.where('published_at > ?', published_at).last
    end

    def prev_post
      self.class.for_feed.where('published_at < ?', published_at).first
    end

    def to_param
      slug.present? ? slug : id
    end
    
    # The content of the Post to be shown in the RSS feed.
    #
    # Returns description when Blogit.configuration.show_post_description is true
    # Returns body when Blogit.configuration.show_post_description is false
    def short_body
      if Blogit.configuration.show_post_description
        description
      else
        body
      end
    end
    
    def comments
      check_comments_config
      super()
    end
    
    def comments=(value)
      check_comments_config
      super(value)
    end

    def publish
      self.state = Blogit.configuration.active_states.first
    end

    def publish!
      self.update_attributes! state: Blogit.configuration.active_states.first
    end
    

    # The blogger who wrote this {Post Post's} display name
    #
    # Returns the blogger's display name as a String if it's set.
    # Returns an empty String if blogger is not present.
    # Raises a ConfigurationError if the method called is not defined on {#blogger}
    def blogger_display_name
      return "" if blogger.blank?
      if blogger.respond_to?(Blogit.configuration.blogger_display_name_method)
        blogger.send(Blogit.configuration.blogger_display_name_method)
      else
        method_name = Blogit.configuration.blogger_display_name_method
        raise ConfigurationError, "#{blogger.class}##{method_name} is not defined"
      end
    end

    # If there's a blogger and that blogger responds to :twitter_username, returns that.
    # Otherwise, returns nil
    def blogger_twitter_username
      if blogger and blogger.respond_to?(:twitter_username)
        blogger.twitter_username
      end
    end
    

    private


    def check_comments_config
      unless Blogit.configuration.include_comments == :active_record
        raise RuntimeError, 
          "Posts only allow active record comments (check blogit configuration)"
      end
    end

    def set_published_at
      if Blogit.configuration.active_states.include? state.try(:to_sym)
        self.published_at = Time.current
      end
    end

    def set_slug
      self.slug ||= title.parameterize
    end
    
  end
end