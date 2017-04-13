class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Define the Entry object
#  class Entry
#    def initialize(title, description)
#      @title = title
#      @description = description
    #end
   # attr_reader :title
  #  attr_reader :description
 # end

	def scrape_reddit
	    require 'open-uri'
	    doc = Nokogiri::HTML(open("https://www.cars.com/for-sale/searchresults.action/?rd=30&zc=&searchSource=QUICK_FORM&moveTo=listing-698591215"))

	    entries = doc.css('.shop-srp-listings__listing')
	    @entriesArray = []
	    entries.each do |entry|
	      title = entry.css('.listing-row__title>a').text.strip
	      link = entry.css('.listing-row__price').text.strip
	      #entry.css('p.title>a')[0]['href']
	      #@entriesArray << Entry.new(title, link)

	      newEntry = Entry.new(title: title, description:link)
	      if Entry.exists?(title: title) || Entry.exists?(description: link)
	      	print 'do nothing'
	      else
	      	#newEntry.save
	      	 newEntry.save
		  end
		  #@entriesArray << Entry.create!(title: title, description: link)


	    end

	    render template: 'scrape_reddit'
	  end





end


