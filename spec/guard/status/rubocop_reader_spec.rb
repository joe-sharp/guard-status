# frozen_string_literal: true

RSpec.describe Guard::Status::RubocopReader do
  subject(:reader) { described_class.new('tmp/rubocop.json') }

  def report(contents)
    FileUtils.mkdir_p('tmp')
    File.write('tmp/rubocop.json', contents)
  end

  it 'is pending before the report exists' do
    expect(reader.result).to eq(Guard::Status::Result.pending)
  end

  it 'succeeds with no offenses' do
    report('{"summary":{"offense_count":0}}')

    expect(reader.result).to eq(Guard::Status::Result.success)
  end

  it 'fails with the number of offenses' do
    report('{"summary":{"offense_count":3}}')

    expect(reader.result).to eq(Guard::Status::Result.new(:failed, '⚠️ (3)'))
  end

  it 'is unknown when the report is not JSON' do
    report('3 files inspected, 1 offense detected')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it 'is unknown when the report has no offense count' do
    report('{"summary":{}}')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it 'is unknown when the report is not an object' do
    report('[1,2]')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it 'is unknown when the summary is not an object' do
    report('{"summary":5}')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it 'is unknown when the path is not a file' do
    FileUtils.mkdir_p('tmp/rubocop.json')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end
end
