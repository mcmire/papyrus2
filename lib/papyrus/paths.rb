
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

  # Signatures:
  #
  # Papyrus.path
  #
  # Get the root path of the project.
  #
  # Papyrus.path(*args)
  #
  # Get a path of a file within this project.
  #
  # Papyrus.path(&block)
  #
  # Yield the block with the root path appended to the load path; this lets
  # you require files within the root path easily.
  #
  # Examples:
  #
  #   # Assuming root path is /code/papyrus
  #   Papyrus.path             #=> /code/papyrus
  #   Papyrus.path('foo/bar')  #=> /code/papyrus/foo/bar
  #   # These are equivalent:
  #   Papyrus.path { require 'foo/bar' }
  #   require Papyrus.path('foo/bar')
  #   require '/code/papyrus/foo/bar'
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

  # Signatures:
  #
  # Papyrus.libpath
  #
  # Get the path of the 'lib' folder within the project.
  #
  # Papyrus.libpath(*args)
  #
  # Get a path of a file within the 'lib' folder.
  #
  # Papyrus.libpath(&block)
  #
  # Yield the block with the 'lib' path appended to the load path; this lets
  # you require files within the lib path easily.
  #
  # Examples:
  #
  #   # Assuming root path is /code/papyrus
  #   Papyrus.libpath             #=> /code/papyrus/lib
  #   Papyrus.libpath('foo/bar')  #=> /code/papyrus/lib/foo/bar
  #   # These are equivalent:
  #   Papyrus.libpath { require 'foo/bar' }
  #   require Papyrus.libpath('foo/bar')
  #   require '/code/papyrus/lib/foo/bar'
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

