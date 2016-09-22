module Blogit
  
  module CommentsHelper
    
    # The commenter's name for a Comment. When the Comment has a website, includes an html
    # link containing their name. Otherwise, just shows the name as a String.
    #
    # comment - A {Comment}
    #
    # Returns a String containing the commenter's name.
    def name_for_comment(comment)
      comment.title + " " + t('wrote', scope: "blogit.comments")
    end
    
  end
end