RSpec.describe Foobara::RemoteGenerator::GenerateTypescript do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:inputs) { { raw_manifest: } }
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }

  it "contains base files", :focus, :profile do
    expect(outcome).to be_success

    expect(result.keys).to any match(/base/)
    expect(command.manifest.organizations.map(&:scoped_short_name)).to include("SomeOrg")
    expect(command.manifest.domains.map(&:scoped_short_name)).to include("Auth")
    expect(command.manifest.commands.map(&:command_name)).to include("CreateUser")
    expect(command.manifest.types.map(&:name)).to include("User")
    expect(command.manifest.entities.map(&:entity_name)).to include("User")

    expect(result["SomeOrg/index.ts"]).to include('export const organizationName = "SomeOrg"')
    expect(result["SomeOrg/Auth/index.ts"]).to include('export const domainName = "Auth"')
  end

  context "when generating typescript for a domain using Foobara::Auth" do
    let(:raw_manifest) { JSON.parse(File.read("spec/fixtures/auth-manifest.json")) }

    it "generates Auth support files and gives commands the proper base classes" do
      expect(outcome).to be_success

      expect(result.keys).to include("Foobara/Auth/LoginCommand.ts")
      expect(result.keys).to include("Foobara/Auth/LogoutCommand.ts")
      expect(result.keys).to include("Foobara/Auth/RequiresAuthCommand.ts")
      expect(result.keys).to include("Foobara/Auth/utils/accessTokens.ts")
    end
  end
end
