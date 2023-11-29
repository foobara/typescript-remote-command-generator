RSpec.describe Foobara::TypescriptRemoteCommandGenerator::Version do
  it "has a version number" do
    expect(Foobara::TypescriptRemoteCommandGenerator::Version::VERSION).to be_a(String)
  end
end
