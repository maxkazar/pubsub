require File.join(File.dirname(__FILE__), 'lib/pubsub')

GEM_SPEC = Gem::Specification.new do |spec|
  spec.name = "pubsub"
  spec.version = "0.0.3"
  spec.extra_rdoc_files = ['README.rdoc']
  spec.summary = %Q{PubSub pattern}
  spec.description = %Q{PubSub pattern}
  spec.authors = "Max Kazarin"
  spec.email = "maxkazargm@gmail.com"
  spec.homepage = "http://github.com/maxkazar/pubsub"
  spec.files = %w(README.rdoc Rakefile) + Dir.glob("{lib,spec}/**/*")
  spec.require_path = "lib"
  spec.add_dependency "ruby_events", ">=0"
  spec.add_development_dependency("rspec", "~>2.6.0")
end