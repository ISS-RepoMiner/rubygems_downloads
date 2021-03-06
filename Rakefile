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
  task :production do
    `git push heroku master`
  end

  task :dangerous do
    branch = `git symbolic-ref -q HEAD`.strip.split('/').last
    if branch
      `git push -f heroku #{branch}:master`
    else
      puts "Current branch not found: #{branch}"
    end
  end
end

namespace :db do
  require_relative 'model/gem_version_download'
  require_relative 'lib/no_sql_store'

  desc 'Create GemVersionDownload table'
  task :create => [:config] do
    begin
      NoSqlStore.new.create_table(GemMiner::GemVersionDownload, 4, 5)
      puts 'GemVersionDownload table created!'
    rescue Aws::DynamoDB::Errors::ResourceInUseException => e
      puts 'GemVersionDownload table already exists'
    rescue => e
      puts "Database error: #{e}"
    end
  end
end

namespace :run do
  task :rackup do
    sh 'bundle exec rackup -o 0.0.0.0 &'
  end

  task :killme do
    sh "pkill -9 rackup"
  end
end
