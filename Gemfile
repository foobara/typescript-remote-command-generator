require_relative "version"

source "https://rubygems.org"
ruby Foobara::TypescriptRemoteCommandGenerator::Version::MINIMUM_RUBY_VERSION

gemspec

# gem "foobara", path: "../foobara"
# gem "foobara-files-generator", path: "../files-generator"

gem "rake"

group :development do
  gem "foobara-rubocop-rules", ">= 1.0.0" # , path: "../rubocop-rules"
  gem "guard-rspec"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "ruby-prof"
end

group :test do
  gem "foobara-spec-helpers", "< 2.0.0"
  gem "rspec-its"
  gem "simplecov"
end
