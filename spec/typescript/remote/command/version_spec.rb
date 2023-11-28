RSpec.describe TypescriptRemoteCommandGenerator::Version do
  it "has a version number" do
    expect(TypescriptRemoteCommandGenerator::Version::VERSION).to be_a(String)
  end
end
