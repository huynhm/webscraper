require 'rake'

namespace :scrape do
	task :site => [:environment] do
	  session = ActionDispatch::Integration::Session.new(Rails.application)
	  session.get "/"
	  puts 'exec scrape'
	  logthis = Logger.new(STDOUT)
	  puts logthis.inspect
	  puts STDOUT
	end
end


