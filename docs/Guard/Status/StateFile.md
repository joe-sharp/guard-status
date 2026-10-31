# Class: Guard::Status::StateFile

- **Defined in:** [`lib/guard/status/state_file.rb`](../../../lib/guard/status/state_file.rb)

Reads a status file: the first word is the state, the rest are its arguments.

  ok
  slow 0.47 0.32
  error something went wrong

`ok` and `error` are built in. Other states are declared with a display, in which `%{1}`, `%{2}` and so on
stand for the arguments, counting from 1, and a severity. A state that is not declared shows as `? <state>` and
counts as failed. A file that cannot be read shows as `?`, and control characters in it, such as terminal escape
sequences, are treated as spaces.

## Constants

### <a id="constant-ARGUMENT"></a>`ARGUMENT`

```ruby
ARGUMENT = /%\{(\d+)\}/
```

### <a id="constant-BUILT_IN"></a>`BUILT_IN`

```ruby
BUILT_IN = {
        "ok" => { display: "✅", severity: :success },
        "error" => { display: "❌", severity: :failed }
      }.freeze
```

## Attributes

### <a id="method-i-path"></a>`#path`

```ruby
attr_reader :path
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(path, states = {})`](#method-i-initialize) |  |
| [`#result`](#method-i-result) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(path, states = {})
```

**Parameters:**

- `path` (`String`) — the status file
- `states` (`Hash{Symbol, String => Hash}`) — states to add to, or override, the built-in ones

**Raises:**

- (`ArgumentError`) — when a state lacks a display, numbers its arguments from 0, or has a severity that is
  not Guard's

### <a id="method-i-result"></a>`#result`

```ruby
def result
```

**Returns:**

- ([`Result`](Result.md))
