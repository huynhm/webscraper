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
	    #doc = Nokogiri::HTML(open("https://www.cars.com/for-sale/searchresults.action/?rd=30&zc=&searchSource=QUICK_FORM&moveTo=listing-698591215"))
		vin = "SCA664S55HUX54239"
	    #doc2 = Nokogiri::HTML(open("https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"))
		#entries = doc2.css('.cg-listing-body')

		

		#@prices = Entry.search(params[:search])
		@pricesArray = []
		search = params[:search]
		searchURL = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"
		if doc2 = Nokogiri::HTML(open(searchURL))
			prices = doc2.css('.cg-listing-body')
			prices.each do |price|
				title = price.css('span')[0].text.strip
				link = price.css('span')[3].text.strip
				link = link[6..-1].strip
				@pricesArray.push([title,link])

				newPrice = Entry.new(title: title, description: link)
				if Entry.exists?(title: title) && Entry.exists?(description: link)
			      	#print 'do nothing'
			    else
			      	#newEntry.save
			      	newPrice.save
				end
			end
		end

		##LISTING
		lastPage = 2
		if params[:seeAll].present?
			lastPage = 50
		end
		$pageCount = 1
		while $pageCount < lastPage do
			page = $pageCount.to_s
			doc = Nokogiri::HTML(open("https://www.cars.com/for-sale/searchresults.action/?page=#{page}&perPage=100&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48152"))

		    entries = doc.css('.shop-srp-listings__listing')
		    @entriesArray = []
		    entries.each do |entry|
		      title = entry.css('.listing-row__title>a').text.strip
		      link = entry.css('.listing-row__price').text.strip
		      #entry.css('p.title>a')[0]['href']
		      #@entriesArray << Entry.new(title, link)

		      newEntry = Entry.new(title: title, description:link)
		      if Entry.exists?(title: title) && Entry.exists?(description: link)
		      	#print 'do nothing'
		      else
		      	#newEntry.save
		      	 newEntry.save
			  end
			  #@entriesArray << Entry.create!(title: title, description: link)
			end
			$pageCount = $pageCount + 1
		end
	    render template: 'scrape_reddit'
	end







end


