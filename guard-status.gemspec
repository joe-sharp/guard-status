# frozen_string_literal: true

require_relative 'lib/guard/status/version'

Gem::Specification.new do |spec|
  spec.name = 'guard-status'
  spec.version = Guard::StatusVersion::VERSION
  spec.authors = ['Joe Sharp']
  spec.email = ['joesharp13@gmail.com']

  spec.summary = 'Guard plugin that prints one status line for all your other guards'
  spec.description = 'guard-status reads what your other Guard plugins recorded, such as RuboCop and RSpec JSON ' \
                     'reports or small status files, and prints a single line summarizing them after every run.'
  spec.homepage = 'https://github.com/joe-sharp/guard-status'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/v#{Guard::StatusVersion::VERSION}"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).select do |f|
      f.start_with?(*%w[lib/ bin/ CHANGELOG.md CODE_OF_CONDUCT.md LICENSE.txt README.md])
    end
  end
  spec.bindir = 'bin'
  spec.executables = ['guard-status-colors']
  spec.require_paths = ['lib']

  spec.add_dependency 'guard', '~> 2.20'
  spec.add_dependency 'guard-compat', '~> 1.2'
end
