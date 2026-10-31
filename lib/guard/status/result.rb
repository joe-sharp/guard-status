# frozen_string_literal: true

require "guard/compat/plugin"

module Guard
  class Status < Plugin
    # What one segment shows, and how bad it is: a severity (`:success`, `:pending` or `:failed`, Guard's own
    # notification types) and the text to display.
    Result = Data.define(:severity, :text) do
      def self.success = new(:success, "✅")

      # Nothing recorded yet, for example before the first run.
      def self.pending = new(:pending, "…")

      # Something was recorded, but it could not be understood.
      def self.unknown(detail = nil) = new(:failed, ["?", detail].compact.join(" "))
    end

    SEVERITIES = %i[success pending failed].freeze
  end
end
