RSpec.describe Foobara::RemoteGenerator::Services::EntityGenerator do
  let(:raw_manifest_json) { File.read("spec/fixtures/foobara-manifest.json") }
  let(:raw_manifest) { JSON.parse(raw_manifest_json) }
  let(:entity_manifest) { Foobara::Manifest::Entity.new(raw_manifest, path) }
  let(:path) { [:type, "SomeOrg::Auth::Referral"] }
  let(:generator) { generator_class.new(entity_manifest) }
  let(:generator_class) { described_class }

  it "has the expected names prefixed as necessary" do
    expect(generator.atom_name).to eq("ReferralAtom")
    expect(generator.loaded_name).to eq("LoadedReferral")
    expect(generator.unloaded_name).to eq("UnloadedReferral")
    expect(generator.aggregate_name).to eq("ReferralAggregate")
    expect(generator.entity_name).to eq("Referral")

    expect(generator.atom_name(1)).to eq("Auth.ReferralAtom")
    expect(generator.loaded_name(1)).to eq("Auth.LoadedReferral")
    expect(generator.unloaded_name(1)).to eq("Auth.UnloadedReferral")
    expect(generator.aggregate_name(1)).to eq("Auth.ReferralAggregate")
    expect(generator.entity_name(1)).to eq("Auth.Referral")

    expect(generator.atom_name(2)).to eq("SomeOrg.Auth.ReferralAtom")
    expect(generator.loaded_name(2)).to eq("SomeOrg.Auth.LoadedReferral")
    expect(generator.unloaded_name(2)).to eq("SomeOrg.Auth.UnloadedReferral")
    expect(generator.aggregate_name(2)).to eq("SomeOrg.Auth.ReferralAggregate")
    expect(generator.entity_name(2)).to eq("SomeOrg.Auth.Referral")
  end

  context "when entity does not have associations" do
    let(:path) { [:type, "SomeOrg::Auth::User"] }

    it "has the expected names prefixed as necessary" do
      expect(generator.atom_name).to eq("LoadedUser")
      expect(generator.loaded_name).to eq("LoadedUser")
      expect(generator.unloaded_name).to eq("UnloadedUser")
      expect(generator.aggregate_name).to eq("UserAggregate")
      expect(generator.entity_name).to eq("User")

      expect(generator.atom_name(1)).to eq("Auth.LoadedUser")
      expect(generator.loaded_name(1)).to eq("Auth.LoadedUser")
      expect(generator.unloaded_name(1)).to eq("Auth.UnloadedUser")
      expect(generator.aggregate_name(1)).to eq("Auth.UserAggregate")
      expect(generator.entity_name(1)).to eq("Auth.User")

      expect(generator.atom_name(2)).to eq("SomeOrg.Auth.LoadedUser")
      expect(generator.loaded_name(2)).to eq("SomeOrg.Auth.LoadedUser")
      expect(generator.unloaded_name(2)).to eq("SomeOrg.Auth.UnloadedUser")
      expect(generator.aggregate_name(2)).to eq("SomeOrg.Auth.UserAggregate")
      expect(generator.entity_name(2)).to eq("SomeOrg.Auth.User")
    end
  end

  describe "#ts_instance_path" do
    context "when it's a loaded generator" do
      let(:generator_class) { Foobara::RemoteGenerator::Services::LoadedEntityGenerator }

      it "gives the loaded path" do
        expect(generator.ts_instance_path).to eq(["LoadedReferral"])
        expect(generator.ts_instance_full_path).to eq(%w[SomeOrg Auth LoadedReferral])
        expect(generator.ts_instance_full_name).to eq("SomeOrg.Auth.LoadedReferral")
      end
    end

    context "when it's an atom generator" do
      let(:generator_class) { Foobara::RemoteGenerator::Services::AtomEntityGenerator }

      it "gives the atom path" do
        expect(generator.ts_instance_path).to eq(["ReferralAtom"])
        expect(generator.ts_instance_full_path).to eq(%w[SomeOrg Auth ReferralAtom])
        expect(generator.ts_instance_full_name).to eq("SomeOrg.Auth.ReferralAtom")
      end
    end
  end
end
