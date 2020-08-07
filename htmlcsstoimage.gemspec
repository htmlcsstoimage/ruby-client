
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "htmlcsstoimage/version"

Gem::Specification.new do |spec|
  spec.name          = "htmlcsstoimage-api"
  spec.version       = HTMLCSSToImage::VERSION
  spec.authors       = ["Mike Coutermarsh", "Jeffrey Needles"]
  spec.email         = ["support@htmlcsstoimage.com"]

  spec.summary       = %q{Ruby wrapper for the HTML/CSS to Image API.}
  spec.description   = %q{Generate images using HTML/CSS and Ruby.}
  spec.homepage      = "https://docs.htmlcsstoimage.com/example-code/ruby"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "> 0.10"
  spec.add_development_dependency "bundler", "> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
