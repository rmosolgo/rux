module Rux
  # A set of strings backed by a radix tree
  class Set
    include Enumerable

    # @param members [Array<String>]
    def initialize(members = [])
      @tree = Rux::Tree.new
      members.each { |m| add(m) }
    end

    # @param member [String]
    # @return [Boolean] true if member was added (false if already present)
    def add(member)
      !!@tree.set(member, nil, :absent)
    end

    # @param member [String]
    # @return [Boolean] true if member was deleted (false if was not present)
    def delete(member)
      !@tree.delete(member, :absent)
    end

    # @param member [String]
    # @return [Boolean] true if member is present
    def include?(member)
      !@tree.get(member, :absent)
    end

    # @return [Integer]
    def size
      @tree.size
    end

    alias :length :size
    alias :count :size
    alias :<< :add
    alias :push :add

    def each
      @tree.each { |k, v| yield(k) }
    end
  end
end
