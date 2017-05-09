require "application_responder"
require "rake"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception

	require 'open-uri'
	require 'nokogiri'

#<!-- <td> <%= p.vin %> </td>  <td> <%= ph.carsdotcom %> </td>  <td> <%= p.cargurus %> </td> -->
	def pricehistory

		vin = params[:vin]
		@ph = Pricehistory.order('created_at ASC').where(vin: vin.to_s)
		@car = Car.where(vin: vin.to_s)[0]

		render template: 'pricehistory'
	end
=begin
<%= form_tag(root_path, :method => "get", id: "search-form") do %>
<%= text_field_tag :search, params[:search], placeholder: "Search CarGurus VIN" %>
<%= submit_tag "SearchCarGurus" %>
<% end %>
=end

	def scrape_reddit
		vin = "SCA664S55HUX54239"
		search = params[:search]
		search = search.to_s.strip
		searchURL = "https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"

		##LISTING
		
		index = -1


		if params[:seeAll].present?
			initializeCars
		end
				
	    render template: 'scrape_reddit'
	end

def initializeCars
		hydra = Typhoeus::Hydra.new
		carsdotcom = "https://www.cars.com"
		pageCount = 10
		lastPage = 11
		while pageCount < lastPage do  
			page = $pageCount.to_s
			carlistings = "https://www.cars.com/for-sale/searchresults.action/?mdId=21138&mkId=20015&page=#{page}&perPage=10&rd=30&searchSource=UTILITY&sf1Dir=DESC&sf1Nm=price&zc=48126"
			request = Typhoeus::Request.new(carlistings, followlocation: true)
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
				      puts "-------#{vin}----------"
				      newCar = Car.new(model: title, vin: vin, carsdotcom: carlink)
				      if Car.where(vin: vin)[0].blank?
				      		newCar.save!				      		
					  end
					  ph = Pricehistory.new(vin: vin, carsdotcom: price)
					  ph.save

					  getCarGurusPrice(vin)

				end
			end
			hydra.queue(request) 
			pageCount = pageCount + 1
		end
		hydra.run
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
					someCar = Car.new(model: model, vin: vin)
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


