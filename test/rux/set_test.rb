require "test_helper"

class RuxSetTest < Minitest::Test
  def test_it_handles_membership
    s = Rux::Set.new(["aaa", "aab", "aac"])
    assert_equal true, s.include?("aab")
    assert_equal 3, s.size
    assert_equal false, s.include?("aad")
    assert_equal true, s.add("aad")
    assert_equal 4, s.size
    assert_equal true, s.include?("aad")
    assert_equal true, s.delete("aaa")
    assert_equal false, s.include?("aaa")
    assert_equal 3, s.size
  end

  def test_it_enumerates_keys
    s = Rux::Set.new(["bbb", "bbbb", "bbbbb"])
    keys = []
    s.each {|k| keys << k.upcase }
    assert_equal(["BBB", "BBBB", "BBBBB"], keys)
    assert_equal(["bbb", "bbbb", "bbbbb"], s.to_a)
  end

  def test_it_enumerates_slices
    skip "Needs support from Rux::Tree first"
  end
end
