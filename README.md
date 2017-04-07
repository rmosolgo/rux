# Rux

[![Build Status](https://travis-ci.org/rmosolgo/rux.svg?branch=master)](https://travis-ci.org/rmosolgo/rux)

Ruby binding to [`antirez/rax`](https://github.com/antirez/rax), a [Radix tree](https://en.wikipedia.org/wiki/Radix_tree) implementation in C.

`Rux::Tree` is a key-value enumerable like `Hash`, but its keys must be strings. Its sweet spot is when:

- The keys are large in size or many in number, but they share some prefixes
- You need to iterate over the keyspace lexicographically (it's stored in alphabetical order) (not supported, see todos)

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
tree = Rux::Tree.new
tree["a"] = 1
tree["ab"] = 2
tree.each { |k, v| puts(k, v) }
# a
# 1
# ab
# 2
tree.size         # => 2
tree["ab"]        # => 2
tree.delete("a")  # => 1
tree.size         # => 1
# fallbacks:
tree.get("x", :not_found)     # => :not_found
tree.delete("x", :not_found)  # => :not_found
tree.set("x", 1, :not_found)  # => :not_found
# previous value:
tree.set("x", 2, :not_found)  # => 1
tree.delete("x")              # => 2
```

API:

- [`Rux::Tree`](http://www.rubydoc.info/github/rmosolgo/rux/master/Rux/Tree)
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
