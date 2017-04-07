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
    tree.set("aaa", Box.new(10))
    tree.set("aab", Box.new(20))
    tree.set("aac", Box.new(30))
    tree.set("aad", Box.new(40))

    assert_equal 4, tree.size

    keys = []
    values = []
    tree.each do |key, value|
      keys << key
      values << value.value
    end
    assert_equal ["aaa", "aab", "aac", "aad"], keys
    assert_equal [10, 20, 30, 40], values
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
    assert_raises(ArgumentError) { tree[9] = 100 }
    assert_raises(ArgumentError) { tree[9]  }
    assert_raises(ArgumentError) { tree.delete(9)  }
    assert_equal 0, tree.size
  end

  def test_get_returns_fallback_if_absent
    tree = Rux::Tree.new
    tree.set("qqq", nil)
    assert_nil tree.get("qqq", :fallback)
    assert_nil tree.get("yyy")
    assert_equal :fallback, tree.get("yyy", :fallback)
  end

  def test_set_returns_the_previous_value_or_fallback
    tree = Rux::Tree.new
    assert_nil tree.set("a", 11)
    assert_equal 11, tree.set("a", 2)
    assert_equal 2, tree.set("a", :x)
    assert_equal :fallback, tree.set("x", 11, :fallback)
  end

  def test_delete_returns_the_previous_value
    tree = Rux::Tree.new
    tree.set("abc", :abc)
    assert_equal :abc, tree.delete("abc")
    assert_nil tree.delete("abc")
    assert_equal :fallback, tree.delete("abc", :fallback)
  end

  def test_it_compacts_nil_values
    skip "it segfaults"
    tree = Rux::Tree.new
    assert_equal 1, tree.node_size
    tree.set("a", :a)
    tree.set("ab", :b)
    assert_equal 3, tree.node_size
    tree.set("abc", nil)
    tree.set("abcd", nil)
    assert_equal 4, tree.size
    assert_equal 3, tree.node_size
    assert_nil tree.get("abc")
    tree.set("abc", 9)
    assert_equal 4, tree.node_size
  end

  def test_segfault
    skip "it segfaults"
    tree = Rux::Tree.new
    tree.set("a", :a)
    tree.set("ab", :ab)
    tree.set("abc", nil)
    tree.set("abcd", nil)
    tree.set("abc", 9)
  end
end
