require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception

	require 'open-uri'
	require 'nokogiri'

	def scrape_reddit
	    
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
			      if Entry.where(title: title, description: link).blank?
			      	 newPrice.save
				  end
			end
		end

		##LISTING
		hydra = Typhoeus::Hydra.new
		lastPage = 2
		if params[:seeAll].present?
			lastPage = 51
		end
		$pageCount = 1
		#while $pageCount < lastPage do
			#page = $pageCount.to_s
			#Typhoeus.get("https://www.cars.com/for-sale/searchresults.action/?page=#{page}&perPage=100&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48152")

			lastPage.times do  
				page = $pageCount.to_s
				request = Typhoeus::Request.new("https://www.cars.com/for-sale/searchresults.action/?page=#{page}&perPage=100&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48152", followlocation: true)
				request.on_complete do |response|
					doc = Nokogiri::HTML(response.body)
				    entries = doc.css('.shop-srp-listings__listing')
				    entries.each do |entry|

					      title = entry.css('.listing-row__title>a').text.strip
					      link = entry.css('.listing-row__price').text.strip
					      #entry.css('p.title>a')[0]['href']
					      #@entriesArray << Entry.new(title, link)

					      newEntry = Entry.new(title: title, description:link)
					      if Entry.where(title: title, description: link).blank?
					      	 newEntry.save
						  end
					end
				end
				hydra.queue(request) 
				$pageCount = $pageCount + 1
			end
			hydra.run



			#doc = Nokogiri::HTML(open("https://www.cars.com/for-sale/searchresults.action/?page=#{page}&perPage=100&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48152"))
		    #doc = Nokogiri::HTML(response.body)
=begin
		    entries = doc.css('.shop-srp-listings__listing')
		    entries.each do |entry|

			      title = entry.css('.listing-row__title>a').text.strip
			      link = entry.css('.listing-row__price').text.strip
			      #entry.css('p.title>a')[0]['href']
			      #@entriesArray << Entry.new(title, link)

			      newEntry = Entry.new(title: title, description:link)
			      if Entry.where(title: title, description: link).blank?
			      	 newEntry.save
				  end
			end
=end
			#$pageCount = $pageCount + 1
		#end


		
	    render template: 'scrape_reddit'
	end







end


