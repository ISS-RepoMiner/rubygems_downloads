
namespace :heroku do
  task :dangerous do
    branch = `git symbolic-ref -q HEAD`.split('/').last
    if branch
      `git push heroku #{branch}:master`
    else
      puts "Current branch not found"
    end
  end
end
