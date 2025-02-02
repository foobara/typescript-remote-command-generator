RSpec.describe Foobara::RemoteGenerator::WriteTypescriptToDisk do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:inputs) { { raw_manifest:, output_directory: } }
  let(:output_directory) { "#{__dir__}/../../tmp/domains" }
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }

  after do
    FileUtils.rm_rf(output_directory)
  end

  it "contains base files" do
    expect(outcome).to be_success

    expect(command.paths_to_source_code["SomeOrg/index.ts"]).to include('export const organizationName = "SomeOrg"')
    expect(command.paths_to_source_code["SomeOrg/Auth/index.ts"]).to include('export const domainName = "Auth"')

    expect(File.exist?("#{output_directory}/typescript-remote-commands-generator.json")).to be true
  end

  context "without a manifest or url" do
    let(:raw_manifest) { nil }

    it "is not successful" do
      expect(outcome).to_not be_success
    end
  end

  context "when using detached entities" do
    let(:raw_manifest) { JSON.parse(File.read("spec/fixtures/detached-manifest.json")) }

    it "contains custom domain and command files" do
      expect(outcome).to be_success

      expect(command.paths_to_source_code["Todo/index.ts"]).to include('export const domainName = "Todo"')
      expect(
        command.paths_to_source_code["Todo/CreateUser/index.ts"]
      ).to include("export class CreateUser extends RemoteCommand<")

      expect(File.exist?("#{output_directory}/typescript-remote-commands-generator.json")).to be true
    end
  end
end
