# guard-status

A one line status to complete your Guard output. Ideal when you have more than one Guard Plugin.

![🔮 Status:  RuboCop: ✅ | Tests: ❌ (2) | Docs: ✅ | Bench: 🐢 (0.47s vs 0.32s)](docs/status.svg)

## Setup

```ruby
# Gemfile
group :development do
  gem 'guard-status'
end
```

```sh
bundle exec guard init status   # adds `guard :status` to your Guardfile
bundle exec guard
```

> [!IMPORTANT]
> **Put `guard :status` last in your Guardfile.** Guard runs plugins in the order they appear, so the last one
> sees what the others just recorded.

## Segments

Each segment is a label and where its result comes from. They are shown in the order given:

```ruby
guard :status, segments: {
  'RuboCop' => { rubocop: 'tmp/rubocop.json' },
  'Tests'   => { rspec: 'tmp/rspec.json' },
  'Docs'    => 'tmp/docs_status.txt',
  'Bench'   => { file: 'tmp/benchmark_status.txt',
                 states: { slow: { display: '🐢 (%{1}s vs %{2}s)', severity: :failed } } }
}
```

Without `segments`, the RuboCop and Tests segments above are shown.

### RuboCop and RSpec

These read the JSON reports of the tools, so the other guards need to write them. Put `--format json --out <path>`
after any other format:

```ruby
guard :rubocop, cli: '--format progress --format json --out tmp/rubocop.json'
guard :rspec, cmd: 'bundle exec rspec --format progress --format json --out tmp/rspec.json'
```

| Segment | Shows |
|---|---|
| no problems | ✅ |
| problems | ⚠️ (3) offenses for RuboCop, ❌ (2) failures for RSpec (errors outside examples count) |
| no report yet | … |
| a report that can't be read | ? |

### Status files

A string, or `file:`, reads a status file. The first word is the state and the rest are its arguments:

```
ok
slow 0.47 0.32
error something went wrong
```

[guard-boondoc](https://github.com/joe-sharp/guard-boondoc) writes this format with its `status_file` option, and
any script can write it.

| State | Shows | Severity |
|---|---|---|
| `ok` | ✅ | success |
| `error` | ❌ | failed |
| an empty or missing file | … | pending |
| anything not declared | `? <state>` | failed |
| a file that can't be read | `?` | failed |

Control characters in the file, such as terminal escape sequences, are treated as spaces.

### Your own states

Declare a state with the `states:` option of a `file:` segment. `display` is what to show, in which `%{1}`, `%{2}`
and so on stand for the arguments after the state, counting from 1, and `severity` is one of `:success`,
`:pending` or `:failed`:

```ruby
'Card' => { file: 'tmp/card_status.txt',
            states: { changed: { display: '🔄', severity: :failed } } }
```

Declaring `ok` or `error` replaces the built-in. A typo in a status file shows up as `? slwo` instead of passing
silently. A state without a `display` or a valid `severity`, or a display that uses `%{0}`, raises an
`ArgumentError` when Guard starts.

## Options

| Option | Default | |
|---|---|---|
| `segments` | RuboCop and Tests | the labels and their sources, in order |
| `title` | `'Status'` | |
| `prefix` | `'🔮'` | shown before the title |
| `title_color` | `93` | `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan` or `:white` (0 to 7), a 256-color number from 0 to 255, or `nil` for none. The title is plain when stdout is not a terminal or `NO_COLOR` is set |
| `notify` | `false` | also send the summary as a Guard notification, with the worst severity as its image |

For example, to change the title, prefix and title color:

```ruby
guard :status, title: 'Guard Status', prefix: '💻', title_color: :green
```

![💻 Guard Status:  RuboCop: ✅ | Tests: ✅](docs/modified-status.svg)

To see the 256 colors and pick a number for `title_color`, run `bundle exec guard-status-colors`.

> [!IMPORTANT]
> **Always put quotes around emoji** (`prefix: '💻'`, not `prefix: 💻`). The Guardfile is Ruby, and an unquoted
> emoji is parsed as a variable or method name, so it will raise an error instead of printing.

## When it prints

On start, reload and run all, and again whenever another guard starts a run in response to a change. It learns
this from the callbacks Guard fires before each task (`run_on_modifications_begin` and the like), not from the files
that changed, so a file nobody is watching, or one a tool writes as a side effect such as `.rspec_status`, prints
nothing. A guard that goes on to fail still counts, since the callback fires before the run. One batch of changes
prints one line, however many guards ran.

RuboCop and RSpec only run the changed files when a file changes, and overwrite their reports, so those segments
count just those files until a full run, such as `all_after_pass`, writes the report again.

The plugin only reports, it never fails a Guard task. Because it prints from its own turn in the batch, it has to
come after the guards it reports on, as described in Setup. Any `watch` lines you give it narrow which batches
reach it.

## Development

```sh
bundle exec rake   # specs and RuboCop
```

## License

MIT, see [LICENSE.txt](LICENSE.txt).
