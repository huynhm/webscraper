require 'rake'
require 'open-uri'
require 'nokogiri'


	task :scrape => [:environment] do
	  puts 'exec scrape'
	  logthis = Logger.new(STDOUT)
	  puts logthis.inspect
	  puts STDOUT
	  puts "_________________TASK BEGIN____________________"
	  getCurrentPrices
	  puts "_________________TASK END______________________"
	end


	def getCurrentPrices
		Car.all.each do |cr|
			#for each car URL get current price
			getURL = cr.urls[0]
			#puts "#{getURL} \n"
			vinDoc = Nokogiri::HTML(open(getURL))
			price = vinDoc.css('.vdp-header__price--primary')[0].text.strip
			puts "#{price} \n"
			if cr.price[0] != price #current Site's different than our db price
				cr.price[0] = price
				cr.save!
			end



		end


	end



	def scrape_reddit
		vin = "SCA664S55HUX54239"

		#@prices = Car.search(params[:search])
		pricesArray = []
		urlsArray = []
		##LISTING
		hydra = Typhoeus::Hydra.new
		index = -1
		prices = []
		urls = []
		@oldPrices = []
		lastPage = 3
		carsdotcom = "https://www.cars.com"
		pageCount = 1

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
				      puts "-------#{vin}----------"
				      prices << price
				      urls << carlink
				      @someCar = Car.new(model: title, price: prices, vin: vin, urls: urls)
				      if Car.where(vin: vin)[0].blank?
				      		@someCar.save!
					  else
							
							@someCar = Car.where(vin: vin)[0]
							if @someCar.urls.include?(carlink)
								index = @someCar.urls.index(carlink)
							    if @someCar.price[index] == price #compare old price with newly retrieved price
							    	##do nothing
							    else
							    	op_index0 = @someCar.oldprices[index].to_s
							    	if 	@someCar.oldprices[index].present?
							    		op_index0 = op_index0 + ', ' + @someCar.price[index].to_s
							    	else
							    		op_index0 = @someCar.price[index].to_s
							    	end
							    	@someCar.oldprices[index] = op_index0

							    	ps_index0 = @someCar.pricestamps[index].to_s
							    	if 	@someCar.pricestamps[index].present?
							    		ps_index0 = ps_index0 + ", "  + Time.now.strftime("%m/%d/%Y %H:%M").to_s
							    	else
							    		ps_index0 = Time.now.strftime("%m/%d/%Y %H:%M").to_s
							    	end
							    	@someCar.pricestamps[index] = ps_index0

							        @someCar.price[index] = price
							        #@someCar.urls.push(carlink)
							        @someCar.save!
							        @someCar = Car.where(vin: vin)[0]
							        #oldPrice = OldPrice.new(vin: vin, oldprice: somePrice)

							       
							    end


							else
								@someCar.urls.push(carlink)
								@someCar.price.push(price)
								@someCar.save!
								@someCar = Car.where(vin: vin)[0]

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
		
	end

	def check_otherprices(vin, siteurl)
		#params vin, url, siteprice
		index = -1
		curprice = -1
		@getCar = Car.where(vin: vin)[0]
		u = 0
		while u < @getCar.urls.size
			othersite = @getCar.urls[u].strip
			if @getCar.urls[u].strip != siteurl #other websites besides siteurl
				#fetch gcURL,
				sitename = @getCar.urls[u].split('.')[1] 
				if sitename == "cars"

				elsif sitename == "cargurus"
					if doc2 = Nokogiri::HTML(open(othersite))
						cars = doc2.css('.cg-listing-body')
						cars.each do |car|
							curprice = car.css('span')[3].text.strip
							curprice = curprice[6..-1].strip
							update_otherprices(index, othersite, curprice)
							@getCar = Car.where(vin: vin)[0]

						end

					end

				end
				#index, @getCar, othersite, curprice
			end
			@getCar.save!
			@getCar = Car.where(vin: vin)[0]
			u += 1 
		end
	end

	def update_otherprices(index, othersite, curprice)
		index = @getCar.urls.index(othersite) #get website index
		if @getCar.price[index] == curprice
			#same prices, do nothing
		else
			#insert current db price into oldprices, and pricestamps, update current db price with new price
	    	op_index = @getCar.oldprices[index].to_s
	    	if 	@getCar.oldprices[index].present?
	    		op_index = op_index + ', ' + @getCar.price[index].to_s
	    	else
	    		op_index = @getCar.price[index].to_s
	    	end
	    	@getCar.oldprices[index] = op_index

	    	ps_index = @getCar.pricestamps[index].to_s
	    	if 	@getCar.pricestamps[index].present?
	    		ps_index = ps_index + ", "  + Time.now.strftime("%m/%d/%Y %H:%M").to_s
	    	else
	    		ps_index = Time.now.strftime("%m/%d/%Y %H:%M").to_s
	    	end
	    	@getCar.pricestamps[index] = ps_index

	        @getCar.price[index] = curprice
	        #@someCar.urls.push(carlink)
	        @getCar.save!

		end
	end

