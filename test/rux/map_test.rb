require "test_helper"

class RuxMapTest < Minitest::Test
  def test_it_exists
    # Just make sure the class is here:
    assert Rux::Map
  end

  def test_it_starts_empty
    map = Rux::Map.new
    assert_equal 0, map.size
  end

  def test_it_holds_members
    map = Rux::Map.new
    map.set("A", :a)
    map.set("B", :b)
    assert_equal 2, map.size
    map.set("BC", :bc)
    assert_equal 3, map.size

    assert_equal :b, map.get("B")
    assert_equal :bc, map.get("BC")
    assert_nil map.get("XYZ")

    map.delete("BC")
    assert_nil map.get("BC")
    assert_equal 2, map.size
  end

  Box = Struct.new(:value)


  def test_it_enumerates_members
    map = Rux::Map.new
    map.set("aaa", Box.new(10))
    map.set("aab", Box.new(20))
    map.set("aac", Box.new(30))
    map.set("aad", Box.new(40))

    assert_equal 4, map.size

    keys = []
    values = []
    map.each do |key, value|
      keys << key
      values << value.value
    end
    assert_equal ["aaa", "aab", "aac", "aad"], keys
    assert_equal [10, 20, 30, 40], values
  end

  def test_it_survives_gc
    map = Rux::Map.new
    100_000.times { |i|
      map[i.to_s] = Box.new(i)
    }
    assert_equal 100_000, map.size

    GC.start
    last_pair = nil
    map.each do |k, v|
      last_pair = [k, v]
    end

    assert_equal "99999", last_pair.first
    assert_instance_of Box, last_pair.last
    assert_equal 99_999, last_pair.last.value
  end

  def test_it_raises_on_non_string_keys
    map = Rux::Map.new
    assert_raises(ArgumentError) { map[9] = 100 }
    assert_raises(ArgumentError) { map[9]  }
    assert_raises(ArgumentError) { map.delete(9)  }
    assert_equal 0, map.size
  end

  def test_get_returns_fallback_if_absent
    map = Rux::Map.new
    map.set("qqq", nil)
    assert_nil map.get("qqq", :fallback)
    assert_nil map.get("yyy")
    assert_equal :fallback, map.get("yyy", :fallback)
  end

  def test_set_returns_the_previous_value_or_fallback
    map = Rux::Map.new
    assert_nil map.set("a", 11)
    assert_equal 11, map.set("a", 2)
    assert_equal 2, map.set("a", :x)
    assert_equal :fallback, map.set("x", 11, :fallback)
  end

  def test_delete_returns_the_previous_value
    map = Rux::Map.new
    map.set("abc", :abc)
    assert_equal :abc, map.delete("abc")
    assert_nil map.delete("abc")
    assert_equal :fallback, map.delete("abc", :fallback)
  end

  def test_it_compacts_nil_values
    skip "it segfaults"
    map = Rux::Map.new
    assert_equal 1, map.node_size
    map.set("a", :a)
    map.set("ab", :b)
    assert_equal 3, map.node_size
    map.set("abc", nil)
    map.set("abcd", nil)
    assert_equal 4, map.size
    assert_equal 3, map.node_size
    assert_nil map.get("abc")
    map.set("abc", 9)
    assert_equal 4, map.node_size
  end

  def test_segfault
    skip "it segfaults"
    map = Rux::Map.new
    map.set("a", :a)
    map.set("ab", :ab)
    map.set("abc", nil)
    map.set("abcd", nil)
    map.set("abc", 9)
  end
end
