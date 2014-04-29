require 'nokogiri'
require 'open-uri'

# Get the Warped Tour bands page
doc = Nokogiri::HTML(open('http://www.vanswarpedtour.com/bands'))

# Create the bands array
bands = Array.new

# Helps iterate through bands array
i = 0

# Iterate through bands on page
doc.css('h4 a').each do |band|
  
  ##################################
  # BAND PARSING
  ##################################
  # Get band name
  band_name = band.content
  
  # Get band thumbnail
  band_thumb = "https://ldbs.s3.amazonaws.com/sites/vwt/images/bands/" << band_name.downcase.gsub(/\s+/, "-") << "/170x130.jpg"
  
  # Get band picture
  band_picture = "https://ldbs.s3.amazonaws.com/sites/vwt/images/bands/" << band_name.downcase.gsub(/\s+/, "-") << "/960x360.jpg"
  
  ##################################
  # GENRE PARSING
  ##################################
  # Store the genres for current band into array
  band_genres = doc.css('.genres')[i].content.split
  
  # Helps iterate through band_genres array
  j = 0
  
  # Iterate through current band's genre
  band_genres.each do |x|
    
    # Must... defend... pop punk...
    # (Basically handles the whole "Pop Punk is two words" thing)
    if(x.eql? "Pop")
      if(band_genres[j + 1].eql? "Punk")
        band_genres[j] = "Pop Punk"
      end
      j = j + 1
    else
  
       # If a band is a pop punk band, delete the "punk" element
      if(band_genres[j - 1].eql? "Pop Punk")
        band_genres.delete_at(j)
      else
        j = j + 1
      end
    end
  end
  
  # Get the band's Warped Tour page
  band_url = "http://vanswarpedtour.com/bands/" << band_name.gsub(/\s+/, "-")
  band_page = Nokogiri::HTML(open(band_url))
  
  ##################################
  # DATE PARSING
  ##################################
  # Create the date array that stores an array of the dates/cities
  band_dates = Array.new
  band_page.css('tr').each do |x|
    
    # Get each date, city, and annoying "buy button"
    temp_array = x.content.split
    
    # Get the date of the show
    date = temp_array[0] << " " << temp_array[1]
    
    # Get the city
    k = 1
    city = ""
    
    # This loop basically iterates through the "temp_array" of the table row and checks to see whether the element has a comma which means the end of the city and the start of the state two-letter code and then stores the two letter code - basically eliminating the spaces and the buy button!
    begin
      k += 1
      city << temp_array[k] << " "
    end while !temp_array[k][-1,1].eql? ","
    k += 1
    city << temp_array[k]
    
    # Store date and city into band_dates array
    band_dates << {'date' => date, 'city' => city}
  end
  
  ##################################
  # SOCIAL PARSING
  ##################################
  # Create the date array that stores an array of the social media sites of a band
  band_social = Array.new
  band_page.css('#main > div:nth-child(3) > div.col-xs-7 > section:nth-child(2) > ul > li > a').each do |x|
    
    # Create a temp array with the class of the li
    temp_array = x['class'].split
    
    # Get just the site
    type = temp_array[0].gsub("si-", "")
    
    # Get the link
    link = x['href']
    
    # Store type and link into band_social array
    band_social << {'type' => type, 'link' => link}
  end
  
  # Store hash of stuff into bands array
  bands << {'band_name' => band_name, 'band_thumb' => band_thumb, 'band_picture' => band_picture, 'band_genres' => band_genres, 'band_dates' => band_dates, 'band_social' => band_social}
  
  ##################################
  # CREATE SQL
  ##################################
  puts "INSERT INTO bands VALUES (#{i}, '#{band_name}', '#{band_thumb}', '#{band_picture}');"
  band_genres.each do |x|
    puts "INSERT INTO genres VALUES (#{i}, '#{x}');"
  end
  band_dates.each do |x|
    puts "INSERT INTO dates VALUES (#{i}, '#{x['date']}, 2014', '#{x['city']}');"
  end
  band_social.each do |x|
    puts "INSERT INTO links VALUES (#{i}, '#{x['type']}', '#{x['link']}');"
  end
  
  i = i + 1
  
end