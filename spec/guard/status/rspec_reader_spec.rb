# frozen_string_literal: true

RSpec.describe(Guard::Status::RspecReader) do
  subject(:reader) { described_class.new("tmp/rspec.json") }

  def report(contents)
    FileUtils.mkdir_p("tmp")
    File.write("tmp/rspec.json", contents)
  end

  it "is pending before the report exists" do
    expect(reader.result).to eq(Guard::Status::Result.pending)
  end

  it "succeeds with no failures" do
    report('{"summary":{"failure_count":0,"errors_outside_of_examples_count":0}}')

    expect(reader.result).to eq(Guard::Status::Result.success)
  end

  it "fails with the number of failures" do
    report('{"summary":{"failure_count":2,"errors_outside_of_examples_count":0}}')

    expect(reader.result).to eq(Guard::Status::Result.new(:failed, "❌ (2)"))
  end

  it "counts errors outside of examples as failures" do
    report('{"summary":{"failure_count":0,"errors_outside_of_examples_count":1}}')

    expect(reader.result).to eq(Guard::Status::Result.new(:failed, "❌ (1)"))
  end

  it "is unknown when the report is cut short" do
    report('{"summary":{"failure_')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it "is unknown when the report has no summary" do
    report("{}")

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it "is unknown when the report is null" do
    report("null")

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end

  it "is unknown when the summary is not an object" do
    report('{"summary":"done"}')

    expect(reader.result).to eq(Guard::Status::Result.unknown)
  end
end
