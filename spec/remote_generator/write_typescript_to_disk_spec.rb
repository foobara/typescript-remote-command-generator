RSpec.describe Foobara::RemoteGenerator::WriteTypescriptToDisk do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:errors_hash) { outcome.errors_hash }
  let(:inputs) do
    {
      raw_manifest:,
      project_directory:,
      output_directory:,
      fail_if_does_not_pass_linter:
    }
  end
  let(:project_directory) { "#{__dir__}/../../tmp/test-app" }
  let(:output_directory) { "#{project_directory}/src/domains" }
  let(:test_app_directory) { "#{__dir__}/../../spec/fixtures/test-app" }
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }
  let(:fail_if_does_not_pass_linter) { true }

  before do
    FileUtils.mkdir_p(File.dirname(project_directory))
    FileUtils.cp_r(test_app_directory, project_directory)
  end

  after do
    FileUtils.rm_rf(project_directory)
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

  context "when using yet another manifest that has led to errors in the past" do
    let(:raw_manifest) { JSON.parse(File.read("spec/fixtures/answer-bot-manifest.json")) }

    it "contains command domain and command files" do
      expect(outcome).to be_success

      expect(
        command.paths_to_source_code["Foobara/Ai/AnswerBot/Ask/index.ts"]
      ).to include("export class Ask extends RemoteCommand")
    end
  end

  context "when using a manifest with several collisions on models named User" do
    let(:raw_manifest) { JSON.parse(File.read("spec/fixtures/blog-rack.json")) }

    it "contains command domain and command files" do
      expect(outcome).to be_success

      paths = command.paths_to_source_code.keys

      expect(paths).to include("Foobara/Auth/Types/User.ts")
      expect(paths).to include("FoobaraDemo/BlogAuth/Types/User.ts")
      expect(paths).to include("FoobaraDemo/Blog/Types/User.ts")
    end
  end
end
