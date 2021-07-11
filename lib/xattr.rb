# frozen_string_literal: true

require "fiddle"
require "fiddle/import"

require_relative "xattr/version"

class Xattr
  class Error < StandardError; end

  module Lib
    extend Fiddle::Importer

    # Don't follow symbolic links
    NOFOLLOW = 0x0001
    # set the value, fail if attr already exists
    CREATE = 0x0002
    # set the value, fail if attr does not exist
    REPLACE = 0x0004

    dlload Fiddle::Handle::DEFAULT
    extern "int listxattr(const char *, void *, int, int)"
    extern "int getxattr(const char *, const char *, void *, int, int, int)"
    extern "int setxattr(const char *, const char *, void *, int, int, int)"
    extern "int removexattr(const char *, const char *, int)"
  end

  def initialize(path)
    @path = path
    @follow_symlinks = true
  end

  # Should we follow symlinks? #set, #get, #list, and #remove normally operate
  # on the target of the path if it is a symbolic link.  If #follow_symlinks
  # is false they will act on the link itself.
  attr_accessor :follow_symlinks

  # Return an Array of all attributes
  #
  # See <tt>man 2 listxattr</tt> for a synopsis of errors that may be raised.
  def list
    options = follow_symlinks_option
    result = allocate_result(Lib.listxattr(@path, nil, 0, options))
    check_error(Lib.listxattr(@path, result, result.size, options))
    result.to_str.split("\000")
  end

  # Get an attribute
  #
  # See <tt>man 2 getxattr</tt> for a synopsis of errors that may be raised.
  def get(attribute)
    options = follow_symlinks_option
    result = allocate_result(Lib.getxattr(@path, attribute, nil, 0, 0, options))
    check_error(Lib.getxattr(@path, attribute, result, result.size, 0, options))
    result.to_s
  end

  alias [] get

  # Set an attribute (with options)
  #
  # Valid key => value pairs for <tt>options:Hash</tt>:
  #
  # * <tt>:create</tt> => +true+ || +false+: fail if the named attribute
  #   already exists. Default=+false+
  # * <tt>:replace</tt> => +true+ || +false+: fail if the named attribute does
  #   not exist. Default=+false+
  #
  # Failure to specify <tt>:create</tt> or :+replace+ allows creation and
  # replacement.
  #
  # See <tt>man 2 setxattr</tt> for a synopsis of errors that may be raised.
  def set(attribute, value, options = {})
    opts = follow_symlinks_option
    opts |= Lib::CREATE if options[:create]
    opts |= Lib::REPLACE if options[:replace]
    value = value.to_s
    check_error(Lib.setxattr(@path, attribute, value, value.size, 0, opts))
    value
  end

  alias []= set

  # Remove an attribute
  #
  # See <tt>man 2 removexattr</tt> for a synopsis of errors that may be
  # raised.
  def remove(attribute)
    value = get(attribute)
    check_error(Lib.removexattr(@path, attribute, follow_symlinks_option))
    value
  end

  private

  # All *xattr() functions return -1 on error
  def check_error(return_code)
    raise SystemCallError.new(nil, Fiddle.last_error) if return_code.negative?
  end

  # Returns an int option to pass to a Lib.*xattr() function
  def follow_symlinks_option
    @follow_symlinks ? 0 : Lib::NOFOLLOW
  end

  # Allocate a string to store results in
  def allocate_result(len)
    check_error(len)
    Fiddle::Pointer[(" " * len)]
  end
end
