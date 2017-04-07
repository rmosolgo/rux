require "benchmark/ips"
require "rux"
require "securerandom"

# This benchmark doesn't highlight what makes rax special
DATA_LEN = 100_000
KEYS_TEST_LEN = 100

def get_key
  "A" + SecureRandom.hex
end

DATA = DATA_LEN.times.map { get_key }
HIT_KEYS = KEYS_TEST_LEN.times.map { DATA[rand(DATA_LEN)] }
MISS_KEYS = KEYS_TEST_LEN.times.map { "B" + get_key }
KEYS = HIT_KEYS + MISS_KEYS

def test_class(cls)
  obj = cls.new
  # Assign a big tree
  DATA.each { |d| obj[d] = d }
  # Make some gets
  KEYS.each { |k| obj[k] }
  # Make some deletes
  KEYS.each { |k| obj.delete(k) }
end

Benchmark.ips do |x|
  x.report("Rux ") { test_class(Rux::Map) }
  x.report("Hash") { test_class(Hash) }
  x.compare!
end
