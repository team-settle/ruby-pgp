require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

RSpec::Core::RakeTask.new(:rcov) do |task|
    task.rcov = true
end

task :default => %w(compile spec)

task :build => :compile
task :spec  => :compile
