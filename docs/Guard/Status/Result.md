# Class: Guard::Status::Result

- **Inherits:** `Data`
- **Defined in:** [`lib/guard/status/result.rb`](../../../lib/guard/status/result.rb)

What one segment shows, and how bad it is: a severity (`:success`, `:pending` or `:failed`, Guard's own
notification types) and the text to display.

## Attributes

### <a id="method-i-severity"></a>`#severity`

```ruby
attr_reader :severity
```

### <a id="method-i-text"></a>`#text`

```ruby
attr_reader :text
```

## Class methods

| Method | Summary |
| --- | --- |
| [`.pending`](#method-c-pending) | Nothing recorded yet, for example before the first run. |
| [`.success`](#method-c-success) |  |
| [`.unknown(detail = nil)`](#method-c-unknown) | Something was recorded, but it could not be understood. |

### <a id="method-c-pending"></a>`.pending`

```ruby
def self.pending
```

Nothing recorded yet, for example before the first run.

### <a id="method-c-success"></a>`.success`

```ruby
def self.success
```

### <a id="method-c-unknown"></a>`.unknown`

```ruby
def self.unknown(detail = nil)
```

Something was recorded, but it could not be understood.
