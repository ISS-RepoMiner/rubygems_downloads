require 'rake/testtask'
require 'config_env/rake_tasks'

task :config do
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
end

desc "Echo to stdout an environment variable"
task :echo_env, [:var] => :config do |t, args|
  puts "ARGS: #{args}"
  puts "#{args[:var]}: #{ENV[args[:var]]}"
end

desc "Run all tests"
Rake::TestTask.new(name=:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end

namespace :deploy do
  task :dangerous do
    branch = `git symbolic-ref -q HEAD`.strip.split('/').last
    if branch
      `git push -f heroku #{branch}:master`
    else
      puts "Current branch not found: #{branch}"
    end
  end
end
