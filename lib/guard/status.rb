# frozen_string_literal: true

require 'guard/compat/plugin'
require_relative 'status/version'
require_relative 'status/line'
require_relative 'status/segment'

module Guard
  # Prints one line summarizing what the other guards recorded.
  #
  # Guard runs plugins in the order of the Guardfile, so this one goes last. It prints after a change only when
  # another guard started a run for it, which it learns from the callbacks Guard fires before each task.
  #
  # @example Guardfile
  #   guard :status, segments: {
  #     'RuboCop' => { rubocop: 'tmp/rubocop.json' },
  #     'Tests'   => { rspec: 'tmp/rspec.json' },
  #     'Docs'    => 'tmp/docs_status.txt',
  #     'Bench'   => { file: 'tmp/benchmark_status.txt',
  #                    states: { slow: { display: '🐢 (%{1}s vs %{2}s)', severity: :failed } } }
  #   }
  class Status < Plugin
    DEFAULT_SEGMENTS = {
      'RuboCop' => { rubocop: 'tmp/rubocop.json' },
      'Tests' => { rspec: 'tmp/rspec.json' }
    }.freeze
    # The tasks that run in response to changes. `_begin` fires even when the run goes on to fail, unlike `_end`.
    RUN_EVENTS = %i[run_all_begin run_on_modifications_begin run_on_additions_begin run_on_removals_begin].freeze

    # @param options [Hash]
    # @option options [Hash{String => String, Hash}] :segments the labels and where their results come from, in the
    #   order to show them
    # @option options [String] :title ('Status')
    # @option options [String] :prefix ('🔮') shown before the title
    # @option options [Symbol, Integer, nil] :title_color (93) a color name from {Line::COLORS}, a 256-color
    #   number from 0 to 255, or nil for none
    # @option options [Boolean] :notify (false) also send the summary as a Guard notification
    # @raise [ArgumentError] when a segment cannot be made sense of
    def initialize(options = {})
      super
      @segments = options.fetch(:segments, DEFAULT_SEGMENTS).map { |label, config| Segment.build(label, config) }
      self.watchers = [Guard::Watcher.new(/./)] if watchers.empty?
      @title = options.fetch(:title, 'Status')
      @others_ran = false
      @followed = {}.compare_by_identity
      build_line({}) # fail on a bad color when Guard starts
    end

    # @return [void]
    def start
      follow_others
      print_status
    end

    # @return [void]
    def reload
      follow_others
      print_status
    end

    # @return [void]
    def run_all
      @others_ran = false
      print_status
    end

    # Prints if another guard has run since the last time, whatever changed.
    #
    # @return [void]
    def run_on_modifications(_paths = nil)
      return unless @others_ran

      @others_ran = false
      print_status
    end
    alias run_on_additions run_on_modifications
    alias run_on_removals run_on_modifications

    private

    # Listens for the other plugins starting a run. Guard reuses the plugins on reload, but this is repeated in case
    # the list has changed, and @followed gives each plugin one callback.
    def follow_others
      Guard.state.session.plugins.all.each do |plugin|
        next if plugin.equal?(self) || @followed.key?(plugin)

        @followed[plugin] = true
        # Callbacks are kept per plugin class, and that is where Guard looks when it fires them
        plugin.class.add_callback(method(:other_ran), plugin, RUN_EVENTS)
      end
    end

    def other_ran(*)
      @others_ran = true
    end

    def print_status
      line = build_line(@segments.to_h { |segment| [segment.label, segment.result] })
      $stdout.puts line
      Compat::UI.notify(line.summary, title: @title, image: line.severity) if options[:notify]
    end

    def build_line(results)
      Line.new(results, title: @title, prefix: options.fetch(:prefix, '🔮'),
                        color: options.fetch(:title_color, 93), colorize: color?)
    end

    # Colors only a terminal, and not when NO_COLOR asks for none (https://no-color.org).
    def color?
      $stdout.tty? && ENV.fetch('NO_COLOR', '').empty?
    end
  end
end
