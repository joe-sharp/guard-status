# frozen_string_literal: true

require "json"
require "guard/compat/plugin"
require_relative "result"

module Guard
  class Status < Plugin
    # Reads a count of problems from the `summary` of a tool's JSON report. Subclasses say how to find the count in it
    # and how to show it.
    class JsonReader
      attr_reader :path

      # @param path [String] the JSON report the tool writes
      def initialize(path)
        @path = path
      end

      # @return [Result]
      def result
        summary = JSON.parse(File.read(path))
        summary = summary["summary"] if summary.is_a?(Hash)
        return Result.unknown unless summary.is_a?(Hash)

        count = count(summary)
        return Result.unknown unless count.is_a?(Integer)

        count.zero? ? Result.success : failure(count)
      rescue Errno::ENOENT
        Result.pending
      rescue JSON::ParserError, SystemCallError
        Result.unknown
      end

      private

      def count(_summary) = raise(NotImplementedError)
      def failure(_count) = raise(NotImplementedError)
    end

    # RuboCop's offenses, from `--format json --out <path>`.
    class RubocopReader < JsonReader
      private

      def count(summary) = summary["offense_count"]
      def failure(count) = Result.new(:failed, "⚠️ (#{count})")
    end

    # RSpec's failures, including errors raised outside any example, from `--format json --out <path>`.
    class RspecReader < JsonReader
      private

      def count(summary)
        failures = summary["failure_count"]
        errors = summary["errors_outside_of_examples_count"] || 0
        failures + errors if failures.is_a?(Integer) && errors.is_a?(Integer)
      end

      def failure(count) = Result.new(:failed, "❌ (#{count})")
    end
  end
end
