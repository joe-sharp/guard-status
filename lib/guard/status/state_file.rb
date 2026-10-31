# frozen_string_literal: true

require "guard/compat/plugin"
require_relative "result"

module Guard
  class Status < Plugin
    # Reads a status file: the first word is the state, the rest are its arguments.
    #
    #   ok
    #   slow 0.47 0.32
    #   error something went wrong
    #
    # `ok` and `error` are built in. Other states are declared with a display, in which `%{1}`, `%{2}` and so on
    # stand for the arguments, counting from 1, and a severity. A state that is not declared shows as `? <state>` and
    # counts as failed. A file that cannot be read shows as `?`, and control characters in it, such as terminal escape
    # sequences, are treated as spaces.
    class StateFile
      BUILT_IN = {
        "ok" => { display: "✅", severity: :success },
        "error" => { display: "❌", severity: :failed }
      }.freeze
      ARGUMENT = /%\{(\d+)\}/

      attr_reader :path

      # @param path [String] the status file
      # @param states [Hash{Symbol, String => Hash}] states to add to, or override, the built-in ones
      # @raise [ArgumentError] when a state lacks a display, numbers its arguments from 0, or has a severity that is
      #   not Guard's
      def initialize(path, states = {})
        @path = path
        @states = BUILT_IN.merge(states.to_h { |name, definition| [name.to_s, normalize(name, definition)] })
      end

      # @return [Result]
      def result
        state, *arguments = File.read(path).scrub.gsub(/[[:cntrl:]]/, " ").split
        return Result.pending unless state

        definition = @states[state] or return Result.unknown(state)
        Result.new(definition[:severity], fill(definition[:display], arguments))
      rescue Errno::ENOENT
        Result.pending
      rescue SystemCallError
        Result.unknown
      end

      private

      def fill(display, arguments)
        display.gsub(ARGUMENT) { arguments[Regexp.last_match(1).to_i - 1] }
      end

      def normalize(name, definition)
        definition = definition.to_h.transform_keys(&:to_sym)
        raise ArgumentError, "state #{name.inspect} needs a display, a String" unless definition[:display].is_a?(String)
        unless SEVERITIES.include?(definition[:severity])
          raise ArgumentError, "state #{name.inspect} needs a severity, one of #{SEVERITIES.inspect}"
        end

        check_arguments(name, definition[:display])

        definition
      end

      def check_arguments(name, display)
        return unless display.scan(ARGUMENT).any? { |(number)| number.to_i < 1 }

        raise ArgumentError, "state #{name.inspect} counts its arguments from 1"
      end
    end
  end
end
