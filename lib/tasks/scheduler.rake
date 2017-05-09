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
			getCarGurusPrice(vin)
		end
	end

	def getCarGurusPrice(vin)
			searchURL = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{vin}"
			if doc2 = Nokogiri::HTML(open(searchURL))
				cars = doc2.css('.cg-listing-body')
				cars.each do |car|
					model = car.css('span')[0].text.strip
					price = car.css('span')[3].text.strip
					price = price[6..-1].strip
					puts "CarsGurus #{price}  #{vin} \n"
					newCar = Car.new(model: model, vin: vin)
					if Car.where(vin: vin)[0].blank?
						newCar.save!
						newPH = Pricehistory.new(vin: vin, cargurus: price)
						newPH.save!
					else
						newPH = Pricehistory.new(vin: vin, cargurus: price)
						newPH.save!

					end
				end
			end
	end
