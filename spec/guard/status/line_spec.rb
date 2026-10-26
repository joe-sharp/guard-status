# frozen_string_literal: true

RSpec.describe Guard::Status::Line do
  subject(:line) { described_class.new(results, title: 'Status', prefix: '🔮') }

  let(:result) { Guard::Status::Result }
  let(:results) do
    { 'RuboCop' => result.new(:failed, '⚠️ (3)'), 'Tests' => result.success, 'Bench' => result.pending }
  end

  it 'matches the line the status scripts print' do
    expect(line.to_s).to eq("\n🔮\e[38;5;93mStatus:\e[0m  RuboCop: ⚠️ (3) | Tests: ✅ | Bench: …")
  end

  it 'colors the title' do
    colored = described_class.new(results, title: 'Status', prefix: '', color: :cyan)

    expect(colored.to_s).to start_with("\n\e[38;5;6mStatus:\e[0m")
  end

  it 'colors the title with a 256-color number' do
    colored = described_class.new(results, title: 'Status', prefix: '', color: 208)

    expect(colored.to_s).to start_with("\n\e[38;5;208mStatus:\e[0m")
  end

  it 'treats a name and its number as the same color' do
    named = described_class.new(results, title: 'Status', prefix: '', color: :cyan)
    numbered = described_class.new(results, title: 'Status', prefix: '', color: 6)

    expect(numbered.to_s).to eq(named.to_s)
  end

  it 'rejects a number outside 0 to 255' do
    expect { described_class.new(results, title: 'Status', prefix: '', color: 256) }
      .to raise_error(ArgumentError, /unknown color 256/)
  end

  it 'leaves the title uncolored when told not to colorize' do
    plain = described_class.new(results, title: 'Status', prefix: '', colorize: false)

    expect(plain.to_s).to start_with("\nStatus:  RuboCop")
  end

  it 'leaves the title uncolored with a nil color' do
    plain = described_class.new(results, title: 'Status', prefix: '', color: nil)

    expect(plain.to_s).to start_with("\nStatus:  RuboCop")
  end

  it 'rejects an unknown color' do
    expect { described_class.new(results, title: 'Status', prefix: '', color: :plaid) }
      .to raise_error(ArgumentError, /unknown color :plaid/)
  end

  it 'summarizes without the title' do
    expect(line.summary).to eq('RuboCop: ⚠️ (3) | Tests: ✅ | Bench: …')
  end

  it 'takes the worst severity' do
    expect(line.severity).to eq(:failed)
  end

  it 'is pending when nothing failed but something is pending' do
    results.delete('RuboCop')

    expect(line.severity).to eq(:pending)
  end

  it 'succeeds when there is nothing to report' do
    expect(described_class.new({}, title: 'Status', prefix: '').severity).to eq(:success)
  end
end
