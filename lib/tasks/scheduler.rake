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
	  getCarGurusPrice
	  getEdmundsPrice
	  puts "_________________TASK END______________________"
	end


	def getCurrentPrices
		#First get Cars.com Prices
		Car.all.each do |cr|
			#for each car URL get current price
			getURL = cr.carsdotcom
			#puts "#{getURL} \n"
			vinDoc = Nokogiri::HTML(open(getURL))
			carsprice = vinDoc.css('.vdp-header__price--primary')[0].text.strip
			vin = vinDoc.css('.breadcrumb-trailing>a')[3].text.strip
			vin = vin[5..-1].strip
			puts "Cars.com #{carsprice}  #{vin} \n"
			newPH = Pricehistory.new(vin: vin, carsdotcom: carsprice)
			newPH.save!
			#getCarGurusPrice(vin)
			#getEdmundsPrice(vin)
		end
	end

	def getEdmundsPrice
		vin = nil
		Car.all.each do |cr|
			vin = cr. vin 
			try = 0
			edmundURL = "https://www.edmunds.com/ford/focus/2016/used/vin/?vin=#{vin}"
			#res = Net::HTTP.get_response(URI.parse(edmundURL))
			# if it returns a good code
			#sleep 1.75
			while try < 5 do
				begin
					if doc = Nokogiri::HTML(open(edmundURL))
						eprice = doc.css(".price-container>span").text.strip
						if doc.css(".price-container>span").present?
							puts "Edmunds Price: #{eprice}"
							someCar = Car.new(vin: vin, edmunds: edmundURL)
							if Car.where(vin: vin)[0].blank?
								someCar.save!
							else
								if Car.where(vin: vin)[0].edmunds.blank?
									upCar = Car.where(vin: vin)[0]
									upCar.update(edmunds: edmundURL)
								end
							end
							newPH = Pricehistory.new(vin: vin, edmunds: eprice)
							newPH.save!
							break

						end
					end
				rescue OpenURI::HTTPError => e
					if e.message.present?
						puts e.message
					end
				end	
				try += 1
			end

		end		
	end


	def getCarGurusPrice
		vin = nil
		Car.all.each do |cr|
			vin = cr.vin
			searchURL = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{vin}"
			if doc2 = Nokogiri::HTML(open(searchURL))
				cars = doc2.css('.cg-listing-body')
				cars.each do |car|
					model = car.css('span')[0].text.strip
					price = car.css('span')[3].text.strip
					price = price[6..-1].strip
					puts "CarsGurus #{price}  #{vin} \n"
					someCar = Car.new(vin: vin, cargurus: searchURL)
					if Car.where(vin: vin)[0].blank?
						someCar.save!
					else
						if Car.where(vin: vin)[0].cargurus.blank?
							upCar = Car.where(vin: vin)[0]
							upCar.update(cargurus: searchURL)
						end
					end
					newPH = Pricehistory.new(vin: vin, cargurus: price)
					newPH.save!

				end
			end
		end
	end



