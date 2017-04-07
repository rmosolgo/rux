# Rux

[![Build Status](https://travis-ci.org/rmosolgo/rux.svg?branch=master)](https://travis-ci.org/rmosolgo/rux)

Ruby binding to [`antirez/rax`](https://github.com/antirez/rax), a [Radix tree](https://en.wikipedia.org/wiki/Radix_tree) implementation in C.

`Rux::Map` is a key-value enumerable like `Hash`, but its keys must be strings. Its sweet spot is when:

- The keys are large in size or many in number, but they share some prefixes
- You need to iterate over the keyspace lexicographically (it's stored in alphabetical order) (not supported, see todos)

`Rux::Set` is a collection of unique values like `Set`, but its values must be strings.

## Installation

Add this line to your application's Gemfile:

```ruby
# not on rubygems ... yet?
# gem 'rux'
gem 'rux', github: 'rmosolgo/rux'
```

## Usage

```ruby
require "rux"
map = Rux::Map.new
map["a"] = 1
map["ab"] = 2
map.each { |k, v| puts(k, v) }
# a
# 1
# ab
# 2
map.size         # => 2
map["ab"]        # => 2
map.delete("a")  # => 1
map.size         # => 1
# fallbacks:
map.get("x", :not_found)     # => :not_found
map.delete("x", :not_found)  # => :not_found
map.set("x", 1, :not_found)  # => :not_found
# previous value:
map.set("x", 2, :not_found)  # => 1
map.delete("x")              # => 2
```

API:

- [`Rux::Map`](http://www.rubydoc.info/github/rmosolgo/rux/master/Rux/Map)
- [`Rux::Set`](http://www.rubydoc.info/github/rmosolgo/rux/master/Rux/Set)

## Todo

- Support cool lexicographical slices via `raxIter`
- Expose `rax`'s lazy enumeration
- Learn how CRuby handles argument errors for variadic methods and do that

## Development

- `bundle exec rake compile`
- `bundle exec rake test`

## License

- This gem: [MIT License](http://opensource.org/licenses/MIT).
- `rax`: BSD 2-clause
