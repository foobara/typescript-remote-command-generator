RSpec.describe Foobara::RemoteGenerator::Typescript do
  it "has a version number" do
    expect(TypescriptRemoteCommandGenerator::Version::VERSION).to be_a(String)
  end
end
