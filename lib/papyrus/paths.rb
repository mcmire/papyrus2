# This module provides two methods: 'path' and 'libpath'. These methods provide
# three things:
#
# 1) a way to get the path for the project and the 'lib' folder inside the
#    project;
#
# 2) a way to get the path for a file within the project, and a file within the
#    'lib' folder;
#
# 3) a way to require files within any of these two locations without having to
#    specify a full path which is free from load-path tampering.
#
module Papyrus
  PATH = ::File.expand_path('../../..', __FILE__)
  LIBPATH = ::File.join(PATH, 'lib')

  # #### Papyrus#path
  #
  # There are three ways to call this:
  #
  # 1. `Papyrus.path` -- Get the root path of the project.
  #
  # 2. `Papyrus.path(*args)` -- Get a path of a file within this project.
  #
  #     ||Arguments:||
  #     * A variadic list of Strings which will be joined to the project path.
  #
  # 3. `Papyrus.path(&block)` -- Provides a non-obtrusive way to require files
  #    within the root path.
  #
  #    ||Arguments:||
  #    * `block` -- The project path is added to the load path before this is
  #      yielded and then popped off afterward. Hence any files required in the
  #      block are guaranteed to look in the project path first.
  #
  # ||Examples:||
  #
  # ~~~ ruby
  # # Assuming root path is /code/papyrus
  # Papyrus.path             #=> /code/papyrus
  # Papyrus.path('foo/bar')  #=> /code/papyrus/foo/bar
  # # These are equivalent:
  # Papyrus.path { require 'foo/bar' }
  # require Papyrus.path('foo/bar')
  # require '/code/papyrus/foo/bar'
  # ~~~
  #
  def self.path(*args)
    rv = ::File.join(PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift(PATH)
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # #### Papyrus.libpath
  #
  # There are three ways to call this:
  #
  # 1. `Papyrus.libpath` -- Get the path of the `lib` folder within the project.
  #
  # 2. `Papyrus.libpath(*args)` -- Get a path of a file within the `lib` folder.
  #
  #     ||Arguments:||
  #     * A variadic list of Strings which will be joined to the lib path.
  #
  # 3. `Papyrus.path(&block)` -- Provides a non-obtrusive way to require files
  #    within the lib path.
  #
  #    ||Arguments:||
  #    * `block` -- The lib path is added to the load path before this is
  #      yielded and then popped off afterward. Hence any files required in the
  #      block are guaranteed to look in the lib path first.
  #
  # ||Examples:||
  #
  # ~~~ ruby
  # # Assuming root path is /code/papyrus
  # Papyrus.libpath             #=> /code/papyrus/lib
  # Papyrus.libpath('foo/bar')  #=> /code/papyrus/lib/foo/bar
  # # These are equivalent:
  # Papyrus.libpath { require 'foo/bar' }
  # require Papyrus.libpath('foo/bar')
  # require '/code/papyrus/lib/foo/bar'
  # ~~~
  #
  def self.libpath(*args)
    rv = ::File.join(LIBPATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift(LIBPATH)
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end
end

