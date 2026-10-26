# Class: Guard::Status::Line

- **Defined in:** [`lib/guard/status/line.rb`](../../../lib/guard/status/line.rb)

The status line made from each segment's result.

## Constants

### <a id="constant-COLORS"></a>`COLORS`

```ruby
COLORS = { black: 0, red: 1, green: 2, yellow: 3, blue: 4, magenta: 5, cyan: 6, white: 7 }.freeze
```

The names are the first eight of the 256 colors, so a name and its number are the same color.

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(results, title:, prefix:, color: 93, colorize: true)`](#method-i-initialize) |  |
| [`#severity`](#method-i-severity) | Returns the worst severity of any result |
| [`#summary`](#method-i-summary) | Returns the labels and their results, without the title |
| [`#to_s`](#method-i-to_s) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(results, title:, prefix:, color: 93, colorize: true)
```

**Parameters:**

- `results` (`Hash{String => `[`Result`](Result.md)`}`) — in the order to show them
- `title` (`String`)
- `prefix` (`String`) — shown before the title
- `color` (`Symbol`, `Integer`, `nil`) — one of [`COLORS`](#constant-COLORS), a 256-color number from 0 to 255, or nil to leave the
  title uncolored
- `colorize` (`Boolean`) — false to print the title plain whatever the color, for output that is not a terminal

**Raises:**

- (`ArgumentError`) — when the color is neither

### <a id="method-i-severity"></a>`#severity`

```ruby
def severity
```

**Returns:**

- (`Symbol`) — the worst severity of any result

### <a id="method-i-summary"></a>`#summary`

```ruby
def summary
```

**Returns:**

- (`String`) — the labels and their results, without the title

### <a id="method-i-to_s"></a>`#to_s`

```ruby
def to_s
```

**Returns:**

- (`String`)
