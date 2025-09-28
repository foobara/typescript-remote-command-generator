require_relative "version"

Gem::Specification.new do |spec|
  spec.name = "foobara-typescript-remote-command-generator"
  spec.version = Foobara::TypescriptRemoteCommandGenerator::Version::VERSION
  spec.authors = ["Miles Georgi"]
  spec.email = ["azimux@gmail.com"]

  spec.summary = "Generates remote commands for Typescript from a foobara manifest"
  spec.homepage = "https://github.com/foobara/typescript-remote-command-generator"

  # Equivalent to SPDX License Expression: Apache-2.0 OR MIT
  spec.license = "Apache-2.0 OR MIT"
  spec.licenses = ["Apache-2.0", "MIT"]

  spec.required_ruby_version = Foobara::TypescriptRemoteCommandGenerator::Version::MINIMUM_RUBY_VERSION

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.add_dependency "foobara", ">= 0.1.14", "< 2.0.0"
  spec.add_dependency "foobara-files-generator", "< 2.0.0"

  spec.files = Dir[
    "lib/**/*",
    "src/**/*",
    "templates/**/*",
    "LICENSE*.txt",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
