require_relative "lib/xattr/version"

Gem::Specification.new do |spec|
  spec.name          = "xattr"
  spec.version       = Xattr::VERSION
  spec.authors       = ["Andre Arko"]
  spec.email         = ["andre@arko.net"]

  spec.summary       = "Manage macOS xattrs from Ruby"
  spec.homepage      = "https://github.com/indirect/xattr"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
