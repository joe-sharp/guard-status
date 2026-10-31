# frozen_string_literal: true

RSpec.describe(Guard::Status) do
  subject(:plugin) { described_class.new(options) }

  let(:options) { {} }
  let(:others) { [] }

  before do
    groups = instance_double(Guard::Internals::Groups, add: nil)
    plugins = instance_double(Guard::Internals::Plugins)
    session = instance_double(Guard::Internals::Session, groups: groups, plugins: plugins)
    allow(Guard).to receive(:state).and_return(instance_double(Guard::Internals::State, session: session))
    allow(plugins).to receive(:all) { others }
    allow(Guard::Compat::UI).to receive(:notify)
  end

  # Runs the block with stdout swapped for a StringIO that does or does not claim to be a terminal.
  def printed(tty:)
    io = StringIO.new
    allow(io).to receive(:tty?).and_return(tty)
    original = $stdout
    $stdout = io
    yield
    io.string
  ensure
    $stdout = original
  end

  def record(path, contents)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
  end

  it "watches every file" do
    expect(Guard::Watcher.match_files(plugin, %w[a.rb docs/b.md])).to eq(%w[a.rb docs/b.md])
  end

  describe "custom watchers" do
    let(:options) { { watchers: [Guard::Watcher.new(/\.rb$/)] } }

    it "watches only what the Guardfile asks for" do
      expect(Guard::Watcher.match_files(plugin, %w[a.rb b.md])).to eq(%w[a.rb])
    end
  end

  describe "#start" do
    it "prints the default segments before anything has run" do
      expect(printed(tty: true) { plugin.start }).to eq("\n🔮\e[38;5;93mStatus:\e[0m  RuboCop: … | Tests: …\n")
    end

    it "prints the title plain when the output is not a terminal" do
      expect(printed(tty: false) { plugin.start }).to eq("\n🔮Status:  RuboCop: … | Tests: …\n")
    end

    it "prints the title plain when NO_COLOR is set" do
      stub_const("ENV", ENV.to_h.merge("NO_COLOR" => "1"))

      expect(printed(tty: true) { plugin.start }).to eq("\n🔮Status:  RuboCop: … | Tests: …\n")
    end

    context "when the reports exist" do
      before do
        record("tmp/rubocop.json", '{"summary":{"offense_count":2}}')
        record("tmp/rspec.json", '{"summary":{"failure_count":0,"errors_outside_of_examples_count":0}}')
      end

      it "prints what they say" do
        expect { plugin.start }.to output(/RuboCop: ⚠️ \(2\) \| Tests: ✅\n\z/).to_stdout
      end
    end

    context "with segments, a title and a prefix" do
      let(:options) do
        { title: "Health", prefix: ">", segments: { "Docs" => "docs.txt", "Tests" => { rspec: "rspec.json" } } }
      end

      it "prints them in order" do
        record("docs.txt", "ok\n")

        expect(printed(tty: true) { plugin.start }).to eq("\n>\e[38;5;93mHealth:\e[0m  Docs: ✅ | Tests: …\n")
      end
    end

    it "rejects a segment it cannot make sense of" do
      expect { described_class.new(segments: { "Docs" => 42 }) }.to raise_error(ArgumentError)
    end
  end

  describe "when other guards have run" do
    let(:options) { { segments: { "Docs" => "docs.txt" } } }
    let(:rubocop) { Class.new(Guard::Plugin).new }
    let(:others) { [rubocop] }

    # What Guard's runner does just before a task of `plugin`
    def run_task(plugin, event = :run_on_modifications_begin)
      plugin.hook(event.to_s)
    end

    before do
      record("docs.txt", "ok\n")
      allow($stdout).to receive(:puts)
      plugin.start
    end

    it "prints again on #reload" do
      plugin.reload

      expect($stdout).to have_received(:puts).twice
    end

    it "prints again on #run_all" do
      plugin.run_all

      expect($stdout).to have_received(:puts).twice
    end

    it "does not print again on the next change after #run_all covered the other guards" do
      run_task(rubocop, :run_all_begin)
      plugin.run_all
      plugin.run_on_modifications(%w[lib/a.rb])

      expect($stdout).to have_received(:puts).twice
    end

    %i[run_on_modifications run_on_additions run_on_removals].each do |hook|
      it "prints on ##{hook} after another guard ran" do
        run_task(rubocop)
        plugin.public_send(hook, %w[lib/a.rb])

        expect($stdout).to have_received(:puts).twice
      end
    end

    %i[run_all_begin run_on_additions_begin run_on_removals_begin].each do |event|
      it "counts #{event} as another guard running" do
        run_task(rubocop, event)
        plugin.run_on_modifications(%w[lib/a.rb])

        expect($stdout).to have_received(:puts).twice
      end
    end

    it "prints nothing when no other guard ran, whatever changed" do
      plugin.run_on_modifications(%w[.rspec_status docs.txt])

      expect($stdout).to have_received(:puts).once
    end

    it "prints once for a batch in which several guards ran" do
      run_task(rubocop)
      run_task(rubocop)
      2.times { plugin.run_on_modifications(%w[lib/a.rb]) }

      expect($stdout).to have_received(:puts).twice
    end

    it "does not count the plugin itself running" do
      run_task(plugin)
      plugin.run_on_modifications(%w[lib/a.rb])

      expect($stdout).to have_received(:puts).once
    end

    it "does not count tasks that are not runs" do
      run_task(rubocop, :start_begin)
      plugin.run_on_modifications(%w[lib/a.rb])

      expect($stdout).to have_received(:puts).once
    end

    it "listens to a guard once, however often it starts or reloads" do
      plugin.reload

      expect(rubocop.class.callbacks[[rubocop, :run_on_modifications_begin]].size).to eq(1)
    end

    context "when the other guard is replaced by a reload" do
      let(:replacement) { Class.new(Guard::Plugin).new }

      it "follows the replacement" do
        others.replace([replacement])
        plugin.reload
        run_task(replacement)
        plugin.run_on_modifications(%w[lib/a.rb])

        expect($stdout).to have_received(:puts).exactly(3).times
      end
    end
  end

  describe "the notify option" do
    let(:options) { { notify: true, segments: { "Docs" => "docs.txt", "Tests" => "tests.txt" } } }

    before { allow($stdout).to receive(:puts) }

    it "sends the summary with the worst severity" do
      record("docs.txt", "ok\n")
      record("tests.txt", "error\n")
      plugin.start

      expect(Guard::Compat::UI).to have_received(:notify).with("Docs: ✅ | Tests: ❌", title: "Status", image: :failed)
    end

    it "sends the title of the line" do
      record("docs.txt", "ok\n")
      described_class.new(title: "Health", notify: true, segments: { "Docs" => "docs.txt" }).start

      expect(Guard::Compat::UI).to have_received(:notify).with("Docs: ✅", title: "Health", image: :success)
    end

    it "sends nothing by default" do
      described_class.new(segments: { "Docs" => "docs.txt" }).start

      expect(Guard::Compat::UI).not_to have_received(:notify)
    end
  end

  it "never fails the task, whatever it reads" do
    record("docs.txt", "garbage\n")
    plugin = described_class.new(segments: { "Docs" => "docs.txt" })

    expect { plugin.start }.to output(/Docs: \? garbage/).to_stdout
  end
end
