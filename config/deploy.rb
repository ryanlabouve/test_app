# TODO: Make Client Template for Capistrano

require 'json'

conf = {}
conf[:app_name] = "test_app"
conf[:server_address] = "192.168.33.10"
conf[:deploy_user] = "deployer"
conf[:github_user] = "ryanlabouve"


#
## ---  Cap specific variables
# 

set :application, conf[:app_name]
set :user,  conf[:deploy_user]
set :deploy_to, "/home/#{conf[:deploy_user]}/apps/#{application}"
set :run_list,  "#{deploy_to}/run_list.json"
# set :deploy_via, :remote_cache
# set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:#{conf[:github_user]}/#{conf[:app_name]}.git"
set :branch, "master"


#
## --- Server info
#

server conf[:server_address], :web
server conf[:server_address], :app
server conf[:server_address], :db, primary: true

#
## --- Cap Config
#

# This enable any prompts that come from remote server
# to work on local terminal
default_run_options[:pty] = true

# Enable remote server to use local github key for authorization
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # only keep the last 5


#
## --- Additions to deploy stuff
#
namespace :deploy do
  # task :setup_config, roles :app do
  #   # Generate runlist and trigger chef

  #   run_list_json = {
  #     :run_list => []
  #   }

  #   File.open('run_list', 'w') { |f| f.write( run_list_json.to_json) }
  #   run "{sudo} chef-solo -j #{run_list_json}"
  # end
  #

  desc "Make sure local git is in sync with remote"
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not in the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
