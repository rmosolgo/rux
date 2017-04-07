require "test_helper"

class RuxTreeTest < Minitest::Test
  def test_it_exists
    # Just make sure the class is here:
    assert Rux::Tree
  end

  def test_it_starts_empty
    tree = Rux::Tree.new
    assert_equal 0, tree.size
  end

  def test_it_holds_members
    tree = Rux::Tree.new
    tree.set("A", :a)
    tree.set("B", :b)
    assert_equal 2, tree.size
    tree.set("BC", :bc)
    assert_equal 3, tree.size

    assert_equal :b, tree.get("B")
    assert_equal :bc, tree.get("BC")
    assert_nil tree.get("XYZ")

    tree.delete("BC")
    assert_nil tree.get("BC")
    assert_equal 2, tree.size
  end

  Box = Struct.new(:value)


  def test_it_enumerates_members
    tree = Rux::Tree.new
    tree.set("aaa", Box.new(1))
    tree.set("aab", Box.new(2))
    tree.set("aac", Box.new(3))
    tree.set("aad", Box.new(4))

    assert_equal 4, tree.size

    keys = []
    values = []
    tree.each do |key, value|
      keys << key
      values << value.value
    end
    assert_equal ["aaa", "aab", "aac", "aad"], keys
    assert_equal [1, 2, 3, 4], values
  end

  def test_it_survives_gc
    tree = Rux::Tree.new
    100_000.times { |i|
      tree[i.to_s] = Box.new(i)
    }
    assert_equal 100_000, tree.size

    GC.start
    last_pair = nil
    tree.each do |k, v|
      last_pair = [k, v]
    end

    assert_equal "99999", last_pair.first
    assert_instance_of Box, last_pair.last
    assert_equal 99_999, last_pair.last.value
  end

  def test_it_raises_on_non_string_keys
    tree = Rux::Tree.new
    assert_raises(ArgumentError) { tree[1] = 1 }
    assert_raises(ArgumentError) { tree[1]  }
    assert_raises(ArgumentError) { tree.delete(1)  }
    assert_equal 0, tree.size
  end

  def test_set_returns_the_previous_value
    tree = Rux::Tree.new
    assert_nil tree.set("a", 1)
    assert_equal 1, tree.set("a", 2)
    assert_equal 2, tree.set("a", :x)
  end

  def test_delete_returns_the_previous_value
    tree = Rux::Tree.new
    tree.set("abc", :abc)
    assert_equal :abc, tree.delete("abc")
    assert_nil tree.delete("abc")
  end
end
