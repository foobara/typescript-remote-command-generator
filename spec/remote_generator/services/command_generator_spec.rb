RSpec.describe Foobara::RemoteGenerator::Services::CommandGenerator do
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }
  let(:command_manifest) { Foobara::Manifest::Command.new(raw_manifest, [:command, :GlobalCommand]) }
  let(:generator) { described_class.new(command_manifest) }

  it "contains base files" do
    expect(generator).to respond_to(:command_name)
  end
end
