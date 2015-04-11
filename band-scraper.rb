require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'ruby-progressbar'
require 'colorize'

def band_list
  bands = Array.new

  page = @agent.get('http://www.vanswarpedtour.com/bands')
  nodes = page.search('.bands-list li')
  pb = ProgressBar.create(
    total: nodes.size,
    format: '%a [%B] %p%% | %E'
  )

  nodes.each do |node|
    band_url = url(node)

    bands << {
      name: name(node),
      thumbnail: thumbnail(node),
      genres: genres(node),
      url: band_url,
      dates: dates(band_url),
      social_networks: social_networks(band_url)
    }

    pb.increment
  end

  bands
end

def name(node)
  node.at_css('h4').text.strip
end

def thumbnail(node)
  node.at_css('.img-thumbnail').attr('src')
end

def genres(band)
  genres = Array.new
  band.css('.genre').each do |genre|
    genres << genre.content.strip
  end
  genres
end

def url(node)
  path = node.at_css('a').attr('href')
  "#{@base_url}#{path}"
end

def dates(band_url)
  dates = Array.new

  page = @agent.get(band_url)
  nodes = page.search('tr')

  nodes.each do |node|
    hash = {
      url: date_url(node),
      ticket_url: ticket_url(node)
    }
    hash.merge!(date(node))
    hash.merge!(location(node))
    dates << hash
  end

  dates
end

def date_url(node)
  path = node.at_css('.date a').attr('href')
  "#{@base_url}#{path}"
end

def ticket_url(node)
  node.at_css('.buy a').attr('href')
end

def date(node)
  date_arr = node.at_css('.date a').text.strip.split

  {
    month: Date::ABBR_MONTHNAMES.index(date_arr.first),
    day: date_arr.last
  }
end

def location(node)
  full = node.css('td')[1].text.strip
  location_arr = full.split(',')

  {
    city: location_arr.first,
    state: location_arr.last
  }
end

def social_networks(band_url)
  social = Hash.new

  page = @agent.get(band_url)
  nodes = page.search('.social li')

  nodes.each do |node|
    social[social_network(node).to_sym] = social_url(node)
  end

  social
end

def social_network(node)
  node.at_css('a').attr('class').split.first.gsub('si-', '')
end

def social_url(node)
  node.at_css('a').attr('href')
end

@agent = Mechanize.new { |a| a.user_agent_alias = 'Mac Safari' }
@base_url = 'http://vanswarpedtour.com'
puts 'Building bands array...'.green
bands = band_list
puts 'Creating json file...'.green
File.write('bands.json', bands.to_json)
puts 'Done!'.green