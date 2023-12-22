RSpec.describe Foobara::RemoteGenerator::WriteTypescriptToDisk do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:inputs) { { raw_manifest:, output_directory: } }
  let(:output_directory) { "#{__dir__}/../../tmp/domains" }
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }

  it "contains base files" do
    expect(outcome).to be_success

    expect(result["SomeOrg/index.ts"]).to include("export class SomeOrgClass extends Organization {")
    expect(result["SomeOrg/Auth/index.ts"]).to include("export class AuthClass extends Domain {")

    expect(File.exist?("#{output_directory}/foobara-generated.json")).to be true
  end
end
