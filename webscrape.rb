require 'open-uri'
require 'nokogiri'

class Entry
	def initialize(title, link)
		@title = title
		@link = link
	end
	attr_reader :title
	attr_reader :link
end



doc = Nokogiri::HTML(open("https://www.reddit.com/"))
entries = doc.css('.entry')
entriesArray = []
# For each entry, 
# we're going to make an Entry object 
# and push it into the array
entries.each do |entry|
	title = entry.css('p.title>a').text
	link = entry.css('p.title>a')[0]['href']
	newEntry = Entry.new(title, link)
	entriesArray << newEntry
end

puts entriesArray[0].title
puts entriesArray[0].link


