require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard-ghpages'

Yard::GHPages::Tasks.install_tasks
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
