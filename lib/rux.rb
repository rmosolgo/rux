require "rux/version"
# Load the compiled extension:
require "rux/rux"
require "rux/set"

module Rux
  # A key-value data store backed by a `rax` Radix tree.
  class Map
    # @!method set(key, value, fallback = nil)
    #   Sets `key` equal to `value` in the tree. Returns the previous value or `fallback`
    #   @param key [String]
    #   @param value [Object]
    #   @param fallback [Object]
    #   @return [Object]
    # @!method get(key, fallback = nil)
    #   Gets the value for `key` in the tree, or `fallback` if it's not present
    #   @param key [String]
    #   @param fallback [Object]
    #   @return [Object]
    # @!method delete(key, fallback = nil)
    #   Deletes `key` from the tree, returning its value if it was present, or `fallback` if it wasn't present.
    #   @param key [String]
    #   @param fallback [Object]
    #   @return [Object]
    # @!method each
    #   Yields each key-value pair to a block, in lexicographical order.
    #   @return [void]
    # @!method size
    #   @return [Integer] The number of pairs in the tree
    # @!method show
    #   Prints a representation of the tree to STDOUT. Just for fun.
    #   @return [void]

    alias :[] :get
    alias :[]= :set
  end
end
