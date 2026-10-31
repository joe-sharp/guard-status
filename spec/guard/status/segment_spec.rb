# frozen_string_literal: true

RSpec.describe(Guard::Status::Segment) do
  describe ".build" do
    it "reads a string as the path of a status file" do
      File.write("docs.txt", "ok\n")
      segment = described_class.build("Docs", "docs.txt")

      expect([segment.label, segment.path, segment.result]).to eq(["Docs", "docs.txt", Guard::Status::Result.success])
    end

    it "builds a RuboCop segment" do
      expect(described_class.build("RuboCop", rubocop: "tmp/rubocop.json").path).to eq("tmp/rubocop.json")
    end

    it "builds an RSpec segment" do
      expect(described_class.build("Tests", rspec: "tmp/rspec.json").path).to eq("tmp/rspec.json")
    end

    it "passes states to a file segment" do
      File.write("bench.txt", "slow 2\n")
      states = { slow: { display: "slow", severity: :failed } }
      segment = described_class.build("Bench", file: "bench.txt", states: states)

      expect(segment.result.severity).to eq(:failed)
    end

    it "accepts string keys" do
      expect(described_class.build("Tests", "rspec" => "tmp/rspec.json").path).to eq("tmp/rspec.json")
    end

    it "turns the label into a string" do
      expect(described_class.build(:Docs, "docs.txt").label).to eq("Docs")
    end

    it "rejects a segment that is neither a path nor a Hash" do
      expect { described_class.build("Docs", 42) }.to raise_error(ArgumentError, /must be a path or a Hash/)
    end

    it "rejects a segment with no source" do
      expect { described_class.build("Docs", states: {}) }.to raise_error(ArgumentError, /exactly one of/)
    end

    it "rejects a segment with two sources" do
      expect { described_class.build("Docs", rubocop: "a", rspec: "b") }.to raise_error(ArgumentError, /exactly one of/)
    end

    it "rejects unknown keys" do
      expect { described_class.build("Tests", rspec: "a", color: "red") }
        .to raise_error(ArgumentError, /unknown keys \[:color\]/)
    end

    it "rejects states on a segment that reads a report" do
      expect { described_class.build("Tests", rspec: "a", states: {}) }.to raise_error(ArgumentError, /unknown keys/)
    end
  end
end
