# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/vendor/"

    enable_coverage :branch

    minimum_coverage line: 90, branch: 90

    add_group "Core", "lib/guard/status"
    add_group "Bin", "bin"
  end
end

require "guard"
require "guard/status"
require "tmpdir"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  # Each example runs in an empty project directory.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) { example.run }
    end
  end
end
