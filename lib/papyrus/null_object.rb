# NullObject implements the *null object pattern*. It's basically a way to
# clean up logic where you are checking for `nil`. So for example, it turns the
# following code:
#
# ~~~ ruby
# def parent
#   @parent  # or nil
# end
#
# # then later...
# parent && parent.get(...)
# ~~~
#
# into:
#
# ~~~ ruby
# def parent
#   @parent || NullObject.new
# end
#
# # then later...
# parent.get(...)
# ~~~
#
# It does this by intercepting all method calls to do nothing.
#
# More here: <http://robots.thoughtbot.com/post/12179019201/design-patterns-in-the-wild-null-object>
#
class NullObject < BasicObject
  def method_missing(*args); end
end
