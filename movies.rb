require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'json'

class Movies
  def find_cinemas(postcode)
    # open it in nokogiri
    doc = Nokogiri::HTML(open('http://www.findanyfilm.com/find-a-cinema-3?townpostcode=' + postcode))

    # parse the main 'cinemas' block
    cinemas = doc.xpath("/html/body//div[@id='content']//div[@class='cinema']/div/div")
  
    # hold the cinema data
    data = Array.new

    # nokogiri thinks this is much deeper
    cinemas.xpath("//h2/a").each { |link|
      # title is the link text, then only keep the text
      title = link.children.first.content
      title.gsub!(/\s+/, " ").strip!

      # extract the actual link
      link = link.attribute("href").content
      # venue id is the first parameter
      venue_id = link.split(/[?&]/)[1]
      # then break the parameter open
      venue_id = venue_id.split(/[=]/)[1]  

      data.push({"venue_id" => venue_id, "title" => title})
    }

    # so, after getting the link data, we smoosh it back together
    # with the distance
    cinemas.each_with_index { |cinema, i|
      # distance is the final text (unwrapped) child.
      distance = cinema.children.last.content
      # only keep the text
      distance.gsub!(/\s+/, " ").strip!
    
      # get the old object
      cinema = data[i]
      cinema["distance"] = distance
    }

    data
  end

  def cinema_details(venue_id)
    # open it in nokogiri
    doc = Nokogiri::HTML(open('http://www.findanyfilm.com/find-a-cinema-3?&venue_id=%s&action=CinemaInfo' % venue_id))

    # grab the cinema block
    cinema = doc.xpath("/html/body//div[@id='content']//div[@class='cinema_content']/div/div[@class='info']//p")

    # address is held as a child of the p tag
    begin
      address = cinema.children[3].content
      address.gsub!(/\s+/, " ").strip!
    rescue NoMethodError
      address = ""
    end

    # phone_number is the same, just lower down
    begin
      phone_number = cinema.children[9].content
      phone_number.gsub!(/\s+/, " ").strip!
    rescue NoMethodError
      phone_number = ""
    end

    # link child contains the cinema url
    begin
      link = cinema.children.at_xpath("//p/a")
      link = link.attribute("href").content
    rescue NoMethodError
      link = ""
    end

    # process the struture of the link
    # (it's laid out as a redirect).
    begin
      link = link.split(/[?&]/)[2]
      link = link.split(/[=]/)[1]
    rescue NoMethodError
      link = ""
    end

    Hash[
      "address" => address,
      "phone_number" => phone_number,
      "link" => link
    ]
  end

  def find_cinemas_detailed(postcode, range = 0..10)
    # fetch all of the cinemas
    cinemas = find_cinemas(postcode)
    
    # hold on to the total amount of cinemas
    total = cinemas.count

    # extract only a range (for pagination)
    cinemas = cinemas[range]
    
    # handle out of range errors
    unless cinemas
      cinemas = []
    end

    # merge with the details
    Hash[:cinemas => cinemas.each { |cinema| 
      venue_id = cinema["venue_id"]
      details = cinema_details(venue_id)
      cinema.merge!(details)
    }, :total => total]
  end

  def get_movie_showings(venue_id, day)
    # fetch the set of screenings
    url = "http://www.findanyfilm.com/find-a-cinema-3?day=%s&venue_id=%s&action=Screenings&townpostcode=" % [day, venue_id]

    response = RestClient.get url

    # extract the HTML from the JSON response
    doc = JSON.parse(response.to_str)
    doc = doc["html"]

    # parse it
    doc = Nokogiri::HTML(doc)

    # extract the showtimes block
    show_times = doc.xpath("/html/body/div[@class='times']//tr")

    # don't process more if there's nothing to process
    if show_times.to_html.include? "Sorry, there are no screenings"
      return []
    end

    data = Array.new

    # link holds a url for the film and the title
    show_times.xpath("//td[@class='title']/a").each { |a| 
      # grab the url and clean it
      link = a.attribute("href").value

      # grab the title and clean it
      begin
        title = a.children.first.content
        title = title.gsub!(/\s+/, " ").strip!
      rescue NoMethodError
        title = ""
      end

      data.push({"title" => title, "link" => link, "time" => []})
    }
  
    # extract the times the film is showing
    show_times.xpath("//td[@class='times']").each_with_index { |td, i|
      showing = data[i]

      # it's also the value of a link
      td.children.each { |e| 
        time = e.content
        # clean it up
        time.gsub!(/\s+/, " ").strip!

        # annoyingly, it has empty tags around it
        if not time.empty?
          showing["time"].push(time)
        end
      }
    }

    data
  end
end
