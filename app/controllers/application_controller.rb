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
		#Cars = doc2.css('.cg-listing-body')

		
		
		#@prices = Car.search(params[:search])
		@pricesArray = []
=begin
<%= form_tag(root_path, :method => "get", id: "search-form") do %>
<%= text_field_tag :search, params[:search], placeholder: "Search VIN" %>
<%= submit_tag "Search" %>
<% end %>



		search = params[:search]
		searchURL = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"

		if doc2 = Nokogiri::HTML(open(searchURL))
			prices = doc2.css('.cg-listing-body')
			prices.each do |price|
				title = price.css('span')[0].text.strip
				link = price.css('span')[3].text.strip
				link = link[6..-1].strip
				@pricesArray.push([title,link])

				newPrice = Car.new(title: title, description: link)
			      if Car.where(title: title, description: link).blank?
			      	 newPrice.save
				  end
			end
		end
=end		

		##LISTING
		hydra = Typhoeus::Hydra.new
		@oldPrices = []
		lastPage = 7
		if params[:seeAll].present?
			lastPage = 8
		end
		carsdotcom = "https://www.cars.com"
		$pageCount = 7
		while $pageCount < lastPage do  
			page = $pageCount.to_s
			request = Typhoeus::Request.new("https://www.cars.com/for-sale/searchresults.action/?mdId=21138&mkId=20015&page=#{page}&perPage=10&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48126", followlocation: true)
			request.on_complete do |response|
				doc = Nokogiri::HTML(response.body)
			    cars = doc.css('.shop-srp-listings__listing')
			    cars.each do |car|
				      title = car.css('.listing-row__title>a').text.strip
				      href = car.css('.listing-row__title-visited>a')[0]["href"].strip
				      carlink = carsdotcom + href

				      #vinReq = Typhoeus::Request.new("https://www.cars.com/vehicledetail/detail/698146367/overview/", followlocation: true)
				      vinDoc = Nokogiri::HTML(open(carlink))
				      vin = vinDoc.css('.breadcrumb-trailing>a')[3].text.strip
				      vin = vin[5..-1].strip

				      price = car.css('.listing-row__price').text.strip

				      newCar = Car.new(model: title, price: price, vin: vin)
				      if Car.where(vin: vin).blank?
				      		newCar.save
						else
					      	someCar = Car.where(vin: vin)[0]
						    if someCar.price != price
						    	someCar.oldprices << someCar.price
						    	someCar.pricestamps << Time.now
						        someCar.price = price
						        someCar.save
						        #oldPrice = OldPrice.new(vin: vin, oldprice: somePrice)
						       
						    end
					  end
					  #@oldPrices = OldPrice.where(vin: vin)
				end
			end
			hydra.queue(request) 
			$pageCount = $pageCount + 1
		end
		hydra.run
		
	    render template: 'scrape_reddit'
	end







end


