module Blogit

  # Inherits from the application's controller instead of ActionController::Base
  class ApplicationController < Blogit::configuration.base_controller.constantize

    helper Blogit::ApplicationHelper
    helper Blogit::LayoutHelper
    helper Blogit::PostsHelper
    helper Blogit::CommentsHelper
    
    helper_method :blogit_conf

    # A helper method to access the {Blogit::configuration} at the class level.
    #
    # Returns a Blogit::Configuration
    def self.blogit_conf
      Blogit::configuration
    end

    # A helper method to access the {Blogit::configuration} at the controller instance
    #   level.
    #
    # Returns a Blogit::Configuration
    def blogit_conf
      self.class.blogit_conf
    end

    def app_user
      self.send(Blogit.configuration.controller_user_method)
    end

  end
  
end