RSpec.describe Foobara::RemoteGenerator::GenerateTypescript do
  let(:command) { described_class.new(inputs) }
  let(:outcome) { command.run }
  let(:result) { outcome.result }
  let(:errors) { outcome.errors }
  let(:inputs) { { raw_manifest: } }
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }

  def out_dir
    "#{__dir__}/../../tmp/domains"
  end

  def write_all_to_tmp(result)
    file_list_file = "#{out_dir}/foobara-generated.json"

    if File.exist?(file_list_file)
      file_list = JSON.parse(File.read(file_list_file))

      file_list = file_list.map { |file| file.split("/").first }

      file_list.uniq.each do |file|
        FileUtils.rm_rf("#{out_dir}/#{file}")
      end

      FileUtils.rm_rf(file_list_file)
    end

    write_to_tmp("foobara-generated.json", result["foobara-generated.json"])

    result.map do |path, contents|
      Thread.new { write_to_tmp(path, contents) unless path == "foobara-generated.json" }
    end.each(&:join)
  end

  def write_to_tmp(path, contents)
    path = "#{out_dir}/#{path}"
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
  end

  it "contains base files" do
    expect(outcome).to be_success

    expect(result.keys).to any match(/base/)
    expect(command.manifest.organizations.map(&:organization_name)).to include("SomeOrg")
    expect(command.manifest.domains.map(&:domain_name)).to include("Auth")
    expect(command.manifest.commands.map(&:command_name)).to include("CreateUser")
    expect(command.manifest.types.map(&:name)).to include("User")
    expect(command.manifest.entities.map(&:entity_name)).to include("User")

    expect(result["SomeOrg/index.ts"]).to include("export class SomeOrgClass extends Organization {")
    expect(result["SomeOrg/Auth/index.ts"]).to include("export class AuthClass extends Domain {")

    write_all_to_tmp(result)
  end
end
