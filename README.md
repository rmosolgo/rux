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
tree.each { |k, v| puts(k) }
# a
# ab
tree.size         # => 2
tree["ab"]        # => 2
tree.delete("a")
tree.size         # => 1
```

## Todo

- Support cool lexicographical slices via `raxIter`
- Expose `rax`'s lazy enumeration
- Expose `rax`'s previous-value API
- Translate `Qnil` to `NULL` in `rax` so that the tree can compact

## Development

- `bundle exec rake compile`
- `bundle exec rake test`

## License

- This gem: [MIT License](http://opensource.org/licenses/MIT).
- `rax`: BSD 2-clause
