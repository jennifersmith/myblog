module Jekyll
  class Post
    # this is extremely icky
    alias_method :my_old_do_layout, :do_layout
    def do_layout(payload, layouts)
      self.data["layout"] ||= "post"
      my_old_do_layout(payload, layouts)
    end
 end
end
