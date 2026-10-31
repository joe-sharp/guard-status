# Class: Guard::Status

- **Inherits:** `Plugin`
- **Defined in:** [`lib/guard/status.rb`](../../lib/guard/status.rb), [`lib/guard/status/json_reader.rb`](../../lib/guard/status/json_reader.rb), [`lib/guard/status/line.rb`](../../lib/guard/status/line.rb), [`lib/guard/status/result.rb`](../../lib/guard/status/result.rb), [`lib/guard/status/segment.rb`](../../lib/guard/status/segment.rb), [`lib/guard/status/state_file.rb`](../../lib/guard/status/state_file.rb)

Prints one line summarizing what the other guards recorded.

Guard runs plugins in the order of the Guardfile, so this one goes last. It prints after a change only when
another guard started a run for it, which it learns from the callbacks Guard fires before each task.

**Examples:**

*Guardfile*

```ruby
guard :status, segments: {
  'RuboCop' => { rubocop: 'tmp/rubocop.json' },
  'Tests'   => { rspec: 'tmp/rspec.json' },
  'Docs'    => 'tmp/docs_status.txt',
  'Bench'   => { file: 'tmp/benchmark_status.txt',
                 states: { slow: { display: '🐢 (%{1}s vs %{2}s)', severity: :failed } } }
}
```

## Namespaces

- [`Guard::Status::JsonReader`](Status/JsonReader.md) — Reads a count of problems from the `summary` of a tool's JSON report.
- [`Guard::Status::Line`](Status/Line.md) — The status line made from each segment's result.
- [`Guard::Status::Result`](Status/Result.md) — What one segment shows, and how bad it is: a severity (`:success`, `:pending` or `:failed`, Guard's own notification types) and the text to display.
- [`Guard::Status::RspecReader`](Status/RspecReader.md) — RSpec's failures, including errors raised outside any example, from `--format json --out <path>`.
- [`Guard::Status::RubocopReader`](Status/RubocopReader.md) — RuboCop's offenses, from `--format json --out <path>`.
- [`Guard::Status::Segment`](Status/Segment.md) — One labelled part of the line, and where its result comes from.
- [`Guard::Status::StateFile`](Status/StateFile.md) — Reads a status file: the first word is the state, the rest are its arguments.

## Constants

### <a id="constant-DEFAULT_SEGMENTS"></a>`DEFAULT_SEGMENTS`

```ruby
DEFAULT_SEGMENTS = {
      "RuboCop" => { rubocop: "tmp/rubocop.json" },
      "Tests" => { rspec: "tmp/rspec.json" }
    }.freeze
```

### <a id="constant-RUN_EVENTS"></a>`RUN_EVENTS`

```ruby
RUN_EVENTS = %i[run_all_begin run_on_modifications_begin run_on_additions_begin run_on_removals_begin].freeze
```

The tasks that run in response to changes. `_begin` fires even when the run goes on to fail, unlike `_end`.

### <a id="constant-SEVERITIES"></a>`SEVERITIES`

```ruby
SEVERITIES = %i[success pending failed].freeze
```

## Instance methods

| Method | Summary |
| --- | --- |
| [`#initialize(options = {})`](#method-i-initialize) |  |
| [`#reload`](#method-i-reload) |  |
| [`#run_all`](#method-i-run_all) |  |
| [`#run_on_additions(_paths = nil)`](#method-i-run_on_additions) | Prints if another guard has run since the last time, whatever changed. |
| [`#run_on_modifications(_paths = nil)`](#method-i-run_on_modifications) | Prints if another guard has run since the last time, whatever changed. |
| [`#run_on_removals(_paths = nil)`](#method-i-run_on_removals) | Prints if another guard has run since the last time, whatever changed. |
| [`#start`](#method-i-start) |  |

### <a id="method-i-initialize"></a>`#initialize`

```ruby
def initialize(options = {})
```

**Parameters:**

- `options` (`Hash`)
  - `:segments` (`Hash{String => String, Hash}`) — the labels and where their results come from, in the
    order to show them
  - `:title` (`String`) — (default: `'Status'`)
  - `:prefix` (`String`) — shown before the title (default: `'🔮'`)
  - `:title_color` (`Symbol`, `Integer`, `nil`) — a color name from [`Line::COLORS`](Status/Line.md#constant-COLORS), a 256-color
    number from 0 to 255, or nil for none (default: `93`)
  - `:notify` (`Boolean`) — also send the summary as a Guard notification (default: `false`)

**Raises:**

- (`ArgumentError`) — when a segment cannot be made sense of

### <a id="method-i-reload"></a>`#reload`

```ruby
def reload
```

**Returns:**

- (`void`)

### <a id="method-i-run_all"></a>`#run_all`

```ruby
def run_all
```

**Returns:**

- (`void`)

### <a id="method-i-run_on_additions"></a>`#run_on_additions`

```ruby
def run_on_additions(_paths = nil)
```

- **Alias for:** [`#run_on_modifications`](#method-i-run_on_modifications)

Prints if another guard has run since the last time, whatever changed.

**Returns:**

- (`void`)

### <a id="method-i-run_on_modifications"></a>`#run_on_modifications`

```ruby
def run_on_modifications(_paths = nil)
```

- **Also known as:** [`#run_on_additions`](#method-i-run_on_additions), [`#run_on_removals`](#method-i-run_on_removals)

Prints if another guard has run since the last time, whatever changed.

**Returns:**

- (`void`)

### <a id="method-i-run_on_removals"></a>`#run_on_removals`

```ruby
def run_on_removals(_paths = nil)
```

- **Alias for:** [`#run_on_modifications`](#method-i-run_on_modifications)

Prints if another guard has run since the last time, whatever changed.

**Returns:**

- (`void`)

### <a id="method-i-start"></a>`#start`

```ruby
def start
```

**Returns:**

- (`void`)
