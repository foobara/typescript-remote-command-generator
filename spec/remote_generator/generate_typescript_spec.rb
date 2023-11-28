RSpec.describe Foobara::RemoteGenerator::GenerateTypescript do
  let(:command) { described_class.new }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }

  it "contains base files" do
    expect(result.keys).to any match(/base/)
  end
end
