module Rux
  # A set of strings backed by a radix tree
  class Set
    include Enumerable

    # @param members [Array<String>]
    def initialize(members = [])
      @map = Rux::Map.new
      members.each { |m| add(m) }
    end

    # @param member [String]
    # @return [Boolean] true if member was added (false if already present)
    def add(member)
      !!@map.set(member, nil, :absent)
    end

    # @param member [String]
    # @return [Boolean] true if member was deleted (false if was not present)
    def delete(member)
      !@map.delete(member, :absent)
    end

    # @param member [String]
    # @return [Boolean] true if member is present
    def include?(member)
      !@map.get(member, :absent)
    end

    # @return [Integer]
    def size
      @map.size
    end

    alias :length :size
    alias :count :size
    alias :<< :add
    alias :push :add

    def each
      @map.each { |k, v| yield(k) }
    end
  end
end
