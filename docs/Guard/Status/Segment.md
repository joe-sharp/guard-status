# Class: Guard::Status::Segment

- **Defined in:** [`lib/guard/status/segment.rb`](../../../lib/guard/status/segment.rb)

One labelled part of the line, and where its result comes from.

## Constants

### <a id="constant-SOURCES"></a>`SOURCES`

```ruby
SOURCES = { rubocop: RubocopReader, rspec: RspecReader, file: StateFile }.freeze
```

## Attributes

### <a id="method-i-label"></a>`#label`

```ruby
attr_reader :label
```

## Class methods

| Method | Summary |
| --- | --- |
| [`.build(label, config)`](#method-c-build) |  |

### <a id="method-c-build"></a>`.build`

```ruby
def self.build(label, config)
```

**Parameters:**

- `label` (`String`) — shown before the result
- `config` (`String`, `Hash`) — a path to a status file, or a Hash with exactly one of `rubocop:`, `rspec:`
  or `file:` set to a path, and for `file:` optionally `states:`

**Returns:**

- ([`Segment`](Segment.md))

**Raises:**

- (`ArgumentError`) — when the configuration cannot be made sense of

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(label, reader)`](#method-i-initialize) |  |
| [`#path`](#method-i-path) | Returns the file this segment reads |
| [`#result`](#method-i-result) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(label, reader)
```

### <a id="method-i-path"></a>`#path`

```ruby
def path
```

**Returns:**

- (`String`) — the file this segment reads

### <a id="method-i-result"></a>`#result`

```ruby
def result
```

**Returns:**

- ([`Result`](Result.md))
