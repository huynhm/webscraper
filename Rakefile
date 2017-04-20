# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'bundler/setup'
require 'resque/tasks'


task 'resque:setup' => :environment

#task "resque:setup" do
#  ENV['QUEUE'] = '* rake environment resque:work'
#end


Rails.application.load_tasks
