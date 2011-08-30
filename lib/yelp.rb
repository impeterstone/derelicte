require 'rubygems'
require 'nokogiri'



# //div[@class="class_name"]
# //div[@id="class_id"]

def parse_photos
  photos = File.read("yelpphotos.html")
  doc = Nokogiri::HTML.parse(photos)
  
  results = Array.new

  doc.xpath("//div[@id=\"mainContent\"]//img").each do |n|  
    photo = Hash.new
    photo['src'] = n['src'].gsub(/\/ms.jpg/,'/l.jpg')
    photo['alt'] = n['alt']

    results << photo
  end

  puts results
end


def parse_places
  places = File.read("yelpplaceserror.html")
  doc = Nokogiri::HTML.parse(places)
  
  results = Array.new

  doc.xpath("//span[@class=\"address\"]").each do |n|  
    place = Hash.new
    puts n.children
    # puts n.xpath('strong/a').first
    # puts n.xpath('a[@title="Call"]').first
    # place['biz'] = n.xpath('strong/a').first['href'].gsub(/\/biz\//, '')
    # place['name'] = n.xpath('strong/a').first.text
    # place['phone'] = n.xpath('a[@title="Call"]').first.text
    # place['distance'] = n.xpath('a[@title="Call"]/following-sibling::text()').first.text.strip
    # place['rating'] = n.xpath('img').first['alt'].strip.gsub(/ star rating/, '')
    # place['reviews'] = n.xpath('a/preceding-sibling::text()')[2].text.strip
    # place['category'] = n.xpath('a/preceding-sibling::text()')[3].text.strip
    # place['price'] = n.xpath('a[@title="Call"]/following-sibling::text()')[1].nil? ? "Price: ?" : n.xpath('a[@title="Call"]/following-sibling::text()')[1].text.strip
    # place['address'] = n.xpath('img/following-sibling::text()[3] | a/preceding-sibling::text()[1]').text.strip.gsub(/ \(/, ' ').gsub(/\n/,'')
    
    results << place
  end

  puts results
end

parse_places