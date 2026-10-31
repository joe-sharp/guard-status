# frozen_string_literal: true

require "guard/compat/plugin"
require_relative "json_reader"
require_relative "state_file"

module Guard
  class Status < Plugin
    # One labelled part of the line, and where its result comes from.
    class Segment
      SOURCES = { rubocop: RubocopReader, rspec: RspecReader, file: StateFile }.freeze

      attr_reader :label

      # @param label [String] shown before the result
      # @param config [String, Hash] a path to a status file, or a Hash with exactly one of `rubocop:`, `rspec:`
      #   or `file:` set to a path, and for `file:` optionally `states:`
      # @raise [ArgumentError] when the configuration cannot be made sense of
      # @return [Segment]
      def self.build(label, config)
        config = { file: config } if config.is_a?(String)
        raise ArgumentError, "segment #{label.inspect} must be a path or a Hash" unless config.is_a?(Hash)

        config = config.transform_keys(&:to_sym)
        source = sources(label, config)
        new(label, reader(source, config))
      end

      def self.sources(label, config)
        sources = SOURCES.keys & config.keys
        raise ArgumentError, "segment #{label.inspect} needs exactly one of #{SOURCES.keys.inspect}" unless sources.one?

        extra = config.keys - sources - ((sources == [:file]) ? [:states] : [])
        raise ArgumentError, "segment #{label.inspect} has unknown keys #{extra.inspect}" unless extra.empty?

        sources.first
      end
      private_class_method :sources

      def self.reader(source, config)
        if source == :file
          StateFile.new(
            config[:file],
            config.fetch(:states, {})
          )
        else
          SOURCES[source].new(config[source])
        end
      end
      private_class_method :reader

      def initialize(label, reader)
        @label = label.to_s
        @reader = reader
      end

      # @return [Result]
      def result = @reader.result

      # @return [String] the file this segment reads
      def path = @reader.path
    end
  end
end
