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
		if doc2 = Nokogiri::HTML(open("https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{search}"))
			prices = doc2.css('.cg-listing-body')
			prices.each do |price|
				title = price.css('span')[3].text.strip
				link = price.css('span')[0].text.strip
				@pricesArray.push([title,link])
			end
		end

		##LISTING
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



=begin
<table>
<% Entry.all.each do |entry| %>
	
	<tr>
  		<td><%= entry.title %></td><td><%= entry.description %></td>
  	</tr>
<% end %>
</table>

	    #vin = "SCA664S55HUX54239"
	    #doc2 = Nokogiri::HTML(open("https://www.cargurus.com/Cars/instantMarketValueFromVIN.action?startUrl=%2F&carDescription.vin=#{vin}"))

	    entries = doc2.css('.cg-listing-body')
	    #doc.css('.shop-srp-listings__listing')
	    @entriesArray = []
	    entries.each do |entry|
	      title = entry.css('span')[3].text.strip
	      # entry.css('.listing-row__title>a').text.strip
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
=end	 

	    render template: 'scrape_reddit'
	  end







end


