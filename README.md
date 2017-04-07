# Rux

Ruby binding to [`antirez/rax`](https://github.com/antirez/rax), a [Radix tree](https://en.wikipedia.org/wiki/Radix_tree) implementation in C.

## Installation

~~Add this line to your application's Gemfile:~~

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

## Todo

- Support cool lexicographical slices via `raxIter`
- Expose `rax`'s lazy enumeration
- Expose `rax`'s previous-value API
- Translate `Qnil` to `NULL` in `rax` so that the tree can compact
- Learn how CRuby handles argument errors for variadic methods and do that

## Development

- `bundle exec rake compile`
- `bundle exec rake test`

## License

- This gem: [MIT License](http://opensource.org/licenses/MIT).
- `rax`: BSD 2-clause
