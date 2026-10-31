# frozen_string_literal: true

RSpec.describe(Guard::Status::StateFile) do
  subject(:state_file) { described_class.new("status.txt", states) }

  let(:states) { {} }

  def record(contents) = File.write("status.txt", contents)

  it "is pending before the file exists" do
    expect(state_file.result).to eq(Guard::Status::Result.pending)
  end

  it "is pending while the file is empty" do
    record("")

    expect(state_file.result).to eq(Guard::Status::Result.pending)
  end

  it "knows ok" do
    record("ok\n")

    expect(state_file.result).to eq(Guard::Status::Result.success)
  end

  it "knows error, whatever the message" do
    record("error boondoc could not read the config\n")

    expect(state_file.result).to eq(Guard::Status::Result.new(:failed, "❌"))
  end

  it "shows an undeclared state, as failed" do
    record("slwo 0.5 0.3\n")

    expect(state_file.result).to eq(Guard::Status::Result.new(:failed, "? slwo"))
  end

  it "is unknown when the path is not a file" do
    FileUtils.mkdir_p("status.txt")

    expect(state_file.result).to eq(Guard::Status::Result.unknown)
  end

  it "reads a file with invalid UTF-8" do
    File.binwrite("status.txt", "ok \xFF\xFE\n")

    expect(state_file.result).to eq(Guard::Status::Result.success)
  end

  it "shows no terminal escape sequences from the file" do
    record("\e]0;pwned\a\e[2J")

    expect(state_file.result.text).not_to match(/[[:cntrl:]]/)
  end

  context "with declared states" do
    let(:states) { { slow: { display: "🐢 (%{1}s vs %{2}s)", severity: :failed } } }

    it "fills the display from the arguments" do
      record("slow 0.47 0.32\n")

      expect(state_file.result).to eq(Guard::Status::Result.new(:failed, "🐢 (0.47s vs 0.32s)"))
    end

    it "leaves out arguments that are missing" do
      record("slow 0.47\n")

      expect(state_file.result.text).to eq("🐢 (0.47s vs s)")
    end

    it "still knows the built-in states" do
      record("ok\n")

      expect(state_file.result).to eq(Guard::Status::Result.success)
    end
  end

  context "when a built-in state is declared" do
    let(:states) { { "error" => { display: "💥 (%{1})", severity: :failed } } }

    it "overrides the built-in" do
      record("error 3\n")

      expect(state_file.result).to eq(Guard::Status::Result.new(:failed, "💥 (3)"))
    end
  end

  describe "a bad declaration" do
    it "needs a display" do
      expect { described_class.new("status.txt", slow: { severity: :failed }) }
        .to raise_error(ArgumentError, /:slow needs a display/)
    end

    it "counts arguments from 1" do
      expect { described_class.new("status.txt", slow: { display: "%{0}", severity: :failed }) }
        .to raise_error(ArgumentError, /:slow counts its arguments from 1/)
    end

    it "needs one of Guard's severities" do
      expect { described_class.new("status.txt", slow: { display: "slow", severity: :meh }) }
        .to raise_error(ArgumentError, /:slow needs a severity/)
    end
  end
end
