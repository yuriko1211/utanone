# frozen_string_literal: true

require_relative "lib/utanone/version"

Gem::Specification.new do |spec|
  spec.name          = "utanone"
  spec.version       = Utanone::VERSION
  spec.authors       = ["yuriko1211"]
  spec.email         = ["yuriko11d@gmail.com"]

  spec.summary       = "Utanone is a helper that counts the number of sounds in Japanese sentences."
  spec.description   = "Utanone is a helper that counts the number of sounds in Japanese sentences."
  spec.homepage      = "https://github.com/yuriko1211/utanone"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/yuriko1211/utanone"
  spec.metadata["changelog_uri"] = "https://github.com/yuriko1211/utanone/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mecab", "~> 0.996"
  spec.add_dependency "natto", "~> 1.2.0"

  spec.add_development_dependency 'dotenv'
end
