require "application_responder"
require "rake"

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
		pricesArray = []
		urlsArray = []

		search = params[:search]
		search = search.to_s.strip
		searchURL = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"

		if doc2 = Nokogiri::HTML(open(searchURL))
			cars = doc2.css('.cg-listing-body')
			cars.each do |car|
				pricesArray = []
				urlsArray = []
				model = car.css('span')[0].text.strip
				price = car.css('span')[3].text.strip
				price = price[6..-1].strip
				pricesArray.push(price)
				urlsArray.push(searchURL)

				newPrice = Car.new(vin: search, model: model, price: pricesArray, urls: urlsArray)
				if Car.where(vin: search)[0].blank?
					newPrice.save!
					puts '@@@@@@@@@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@'
				else
					#params vin, url, siteprice
					existCar = Car.where(vin: search)[0]
					if existCar.urls.include?(searchURL) #website already there => check if current site's prices equals to db's current site price
						
						index = existCar.urls.index(searchURL) #get website index
						if existCar.price[index] == price
							#same prices, do nothing
						else
							#insert current db price into oldprices, and pricestamps, update current db price with new price
					    	op_index = existCar.oldprices[index].to_s
					    	if 	existCar.oldprices[index].present?
					    		op_index = op_index + ', ' + existCar.price[index].to_s
					    	else
					    		op_index = existCar.price[index].to_s
					    	end
					    	existCar.oldprices[index] = op_index

					    	ps_index = existCar.pricestamps[index].to_s
					    	if 	existCar.pricestamps[index].present?
					    		ps_index = ps_index + ", "  + Time.now.strftime("%m/%d/%Y %H:%M").to_s
					    	else
					    		ps_index = Time.now.strftime("%m/%d/%Y %H:%M").to_s
					    	end
					    	existCar.pricestamps[index] = ps_index

					        existCar.price[index] = price
					        #someCar.urls.push(carlink)
					        existCar.save! 
						end 
						
					else #VIN exists, but new website, get price on that new website
						existCar.urls.push(searchURL)
						existCar.price.push(price)
						existCar.save!
						

					end

				end
			end
		end
		

		##LISTING
		hydra = Typhoeus::Hydra.new
		index = -1
		prices = []
		urls = []
		@oldPrices = []
		lastPage = 8
		if params[:seeAll].present?
			lastPage = 8
		end
		carsdotcom = "https://www.cars.com"
		pageCount = 7

		while pageCount < lastPage do  
			page = $pageCount.to_s
			carlistings = "https://www.cars.com/for-sale/searchresults.action/?mdId=21138&mkId=20015&page=#{page}&perPage=10&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48126"
			request = Typhoeus::Request.new(carlistings, followlocation: true)
			request.on_complete do |response|
				doc = Nokogiri::HTML(response.body)
			    cars = doc.css('.shop-srp-listings__listing')
			    cars.each do |car|
			    	  prices = []
			    	  urls = []
				      title = car.css('.listing-row__title>a').text.strip
				      href = car.css('.listing-row__title-visited>a')[0]["href"].strip
				      carlink = carsdotcom + href

				      #vinReq = Typhoeus::Request.new("https://www.cars.com/vehicledetail/detail/698146367/overview/", followlocation: true)
				      vinDoc = Nokogiri::HTML(open(carlink))
				      vin = vinDoc.css('.breadcrumb-trailing>a')[3].text.strip
				      vin = vin[5..-1].strip

				      price = car.css('.listing-row__price').text.strip
				      puts "-------#{price}----------"
				      prices << price
				      urls << carlink
				      newCar = Car.new(model: title, price: prices, vin: vin, urls: urls)
				      if Car.where(vin: vin)[0].blank?
				      		newCar.save!
					  else
							
							someCar = Car.where(vin: vin)[0]
							if someCar.urls.include?(carlink)
								index = someCar.urls.index(carlink)
							    if someCar.price[index] == price #compare old price with newly retrieved price
							    	##do nothing
							    else
							    	op_index0 = someCar.oldprices[index].to_s
							    	if 	someCar.oldprices[index].present?
							    		op_index0 = op_index0 + ', ' + someCar.price[index].to_s
							    	else
							    		op_index0 = someCar.price[index].to_s
							    	end
							    	someCar.oldprices[index] = op_index0

							    	ps_index0 = someCar.pricestamps[index].to_s
							    	if 	someCar.pricestamps[index].present?
							    		ps_index0 = ps_index0 + ", "  + Time.now.strftime("%m/%d/%Y %H:%M").to_s
							    	else
							    		ps_index0 = Time.now.strftime("%m/%d/%Y %H:%M").to_s
							    	end
							    	someCar.pricestamps[index] = ps_index0

							        someCar.price[index] = price
							        #someCar.urls.push(carlink)
							        someCar.save!
							        someCar = Car.where(vin: vin)[0]
							        #oldPrice = OldPrice.new(vin: vin, oldprice: somePrice)

							       
							    end


							else
								someCar.urls.push(carlink)
								someCar.price.push(price)
								someCar.save!
								someCar = Car.where(vin: vin)[0]

							end
							check_otherprices(vin, carlink)

							

					  end
					  #@oldPrices = OldPrice.where(vin: vin)
				end
			end
			hydra.queue(request) 
			pageCount = pageCount + 1
		end
		hydra.run
		
	    render template: 'scrape_reddit'
	end

	def check_otherprices(vin, siteurl)
		#params vin, url, siteprice
		index = -1
		curprice = -1
		getCar = Car.where(vin: vin)[0]
		u = 0
		while u < getCar.urls.size
			othersite = getCar.urls[u].strip
			if getCar.urls[u].strip != siteurl #other websites besides siteurl
				#fetch gcURL,
				sitename = getCar.urls[u].split('.')[1] 
				if sitename == "cars"

				elsif sitename == "cargurus"
					if doc2 = Nokogiri::HTML(open(othersite))
						cars = doc2.css('.cg-listing-body')
						cars.each do |car|
							curprice = car.css('span')[3].text.strip
							curprice = curprice[6..-1].strip
							update_otherprices(index, getCar, othersite, curprice)
							getCar = Car.where(vin: vin)[0]

						end

					end

				end
				#index, getCar, othersite, curprice
			end
			getCar.save!
			getCar = Car.where(vin: vin)[0]
			u += 1 
		end
	end

	def update_otherprices(index, getCar, othersite, curprice)
		index = getCar.urls.index(othersite) #get website index
		if getCar.price[index] == curprice
			#same prices, do nothing
		else
			#insert current db price into oldprices, and pricestamps, update current db price with new price
	    	op_index = getCar.oldprices[index].to_s
	    	if 	getCar.oldprices[index].present?
	    		op_index = op_index + ', ' + getCar.price[index].to_s
	    	else
	    		op_index = getCar.price[index].to_s
	    	end
	    	getCar.oldprices[index] = op_index

	    	ps_index = getCar.pricestamps[index].to_s
	    	if 	getCar.pricestamps[index].present?
	    		ps_index = ps_index + ", "  + Time.now.strftime("%m/%d/%Y %H:%M").to_s
	    	else
	    		ps_index = Time.now.strftime("%m/%d/%Y %H:%M").to_s
	    	end
	    	getCar.pricestamps[index] = ps_index

	        getCar.price[index] = curprice
	        #someCar.urls.push(carlink)
	        getCar.save!

		end
	end




end


