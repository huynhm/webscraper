class Entry < ApplicationRecord



	
	def self.search(search)
		require 'open-uri'
		vin = "SCA664S55HUX54239"
	    doc2 = Nokogiri::HTML(open("https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"))
		entries = doc2.css('.cg-listing-body')

		
		where("title LIKE ?", "%#{search}%") 

	end


end
