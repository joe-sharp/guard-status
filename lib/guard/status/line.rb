# frozen_string_literal: true

require 'guard/compat/plugin'
require_relative 'result'

module Guard
  class Status < Plugin
    # The status line made from each segment's result.
    class Line
      # The names are the first eight of the 256 colors, so a name and its number are the same color.
      COLORS = { black: 0, red: 1, green: 2, yellow: 3, blue: 4, magenta: 5, cyan: 6, white: 7 }.freeze

      # @param results [Hash{String => Result}] in the order to show them
      # @param title [String]
      # @param prefix [String] shown before the title
      # @param color [Symbol, Integer, nil] one of {COLORS}, a 256-color number from 0 to 255, or nil to leave the
      #   title uncolored
      # @param colorize [Boolean] false to print the title plain whatever the color, for output that is not a terminal
      # @raise [ArgumentError] when the color is neither
      def initialize(results, title:, prefix:, color: 93, colorize: true)
        unless color.nil? || COLORS.key?(color) || (color.is_a?(Integer) && color.between?(0, 255))
          raise ArgumentError, "unknown color #{color.inspect}, use #{COLORS.keys.join(', ')} or a number from 0 to 255"
        end

        @results = results
        @title = title
        @prefix = prefix
        @color = color
        @colorize = colorize
      end

      # @return [String] the labels and their results, without the title
      def summary
        @results.map { |label, result| "#{label}: #{result.text}" }.join(' | ')
      end

      # @return [Symbol] the worst severity of any result
      def severity
        @results.values.map(&:severity).max_by { |severity| SEVERITIES.index(severity) } || :success
      end

      # @return [String]
      def to_s
        "\n#{@prefix}#{colored_title}  #{summary}"
      end

      private

      def colored_title
        return "#{@title}:" unless @color && @colorize

        "\e[38;5;#{COLORS.fetch(@color, @color)}m#{@title}:\e[0m"
      end
    end
  end
end
