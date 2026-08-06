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
      fail_if_does_not_pass_linter:,
      auto_dirty_queries:
    }
  end
  let(:project_directory) { "#{__dir__}/../../tmp/test-app" }
  let(:output_directory) { "#{project_directory}/src/domains" }
  let(:test_app_directory) { "#{__dir__}/../../spec/fixtures/test-app" }
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }
  let(:fail_if_does_not_pass_linter) { true }
  let(:auto_dirty_queries) { true }

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

  context "when auto_dirty_queries is off" do
    let(:auto_dirty_queries) { false }

    it "neither defines nor calls dirtyQueries" do
      # The definition is already behind auto_dirty_queries?, so calling it
      # unconditionally left every successful command raising
      # "TypeError: this.dirtyQueries is not a function". It is a runtime error
      # rather than a type error, so tsc and the linter are both clean and it
      # only appears in a browser.
      expect(outcome).to be_success

      remote_command = command.paths_to_source_code["base/RemoteCommand.ts"]

      expect(remote_command).to_not include("dirtyQueries")
    end
  end

  context "when a command requires authentication but the app has no Foobara::Auth" do
    let(:raw_manifest) do
      manifest = JSON.parse(raw_manifest_json)
      # Any command will do; this manifest contains no Foobara::Auth at all.
      manifest["command"]["FoobaraAi::Ask"]["requires_authentication"] = true
      manifest
    end

    it "does not emit a RequiresAuthCommand it cannot support" do
      # Emitting it here used to produce imports of files that were never
      # generated, so be_success is the linter failing the project.
      expect(outcome).to be_success

      expect(command.paths_to_source_code.keys).to_not include("Foobara/Auth/RequiresAuthCommand.ts")
    end

    it "still generates the command itself" do
      expect(outcome).to be_success
      expect(command.paths_to_source_code.keys).to include("FoobaraAi/Ask/index.ts")
    end
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
