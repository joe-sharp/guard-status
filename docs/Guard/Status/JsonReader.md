# Class: Guard::Status::JsonReader

- **Defined in:** [`lib/guard/status/json_reader.rb`](../../../lib/guard/status/json_reader.rb)

Reads a count of problems from the `summary` of a tool's JSON report. Subclasses say how to find the count in it
and how to show it.

## Attributes

### <a id="method-i-path"></a>`#path`

```ruby
attr_reader :path
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(path)`](#method-i-initialize) |  |
| [`#result`](#method-i-result) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(path)
```

**Parameters:**

- `path` (`String`) — the JSON report the tool writes

### <a id="method-i-result"></a>`#result`

```ruby
def result
```

**Returns:**

- ([`Result`](Result.md))
