
namespace :heroku do
  task :dangerous do
    branch = `git symbolic-ref -q HEAD`.strip.split('/').last
    if branch
      `git push -f heroku #{branch}:master`
    else
      puts "Current branch not found"
    end
  end
end
