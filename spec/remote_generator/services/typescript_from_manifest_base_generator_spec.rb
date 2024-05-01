RSpec.describe Foobara::RemoteGenerator::Services::TypescriptFromManifestBaseGenerator do
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }
  let(:entity_manifest) { Foobara::Manifest::Entity.new(raw_manifest, path) }
  let(:path) { [:type, "SomeOrg::Auth::Referral"] }
  let(:generator) { generator_class.new(entity_manifest) }
  let(:generator_class) { described_class }

  describe "#value_to_ts_value" do
    subject { generator.value_to_ts_value(value) }

    context "when string" do
      let(:value) { "foo" }

      it { is_expected.to eq("\"foo\"") }
    end

    context "when symbol" do
      let(:value) { :foo }

      it { is_expected.to eq("\"foo\"") }
    end
  end
end
