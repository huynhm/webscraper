
task :scrape => :environment do
  session = ActionDispatch::Integration::Session.new(Rails.application)
  session.get "/"
  puts 'exec scrape'
  logthis = Logger.new(STDOUT)
  puts logthis.info 
end

