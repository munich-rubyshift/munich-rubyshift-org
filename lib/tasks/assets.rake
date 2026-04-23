if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].clear
end

namespace :assets do
  desc "Build frontend assets with yarn"
  task :precompile do
    system("yarn build", exception: true)
  end
end

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance([ "assets:precompile" ])
end
