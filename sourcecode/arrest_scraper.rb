require 'date'
require 'arrest_day'
require 'arrest'
require 'nokogiri'
require 'open-uri'

class ArrestScraper
  attr_accessor :date, :number_of_days, :base_consume_url  

  def initialize
    @date = Date.today
    @number_of_days = 0
    @base_consume_url = 'http://www.iowa-city.org/icgov/apps/police/blotter.asp'
  end
  
  def process(number_of_days = @number_of_days, date = @date, base_consume_url = @base_consume_url)
    @date = date
    @number_of_days = number_of_days
    @base_consume_url = base_consume_url
        
    results = [process_url(@date)]
    (1..@number_of_days).to_a.each do |d|
      results << process_url(@date - d)
    end
    
    return results
  end
  
  private
  
  def process_url(calc_date)
    url = @base_consume_url + '?date=' + calc_date.strftime("%m%d%Y")
    arrest_day = ArrestDay.new(calc_date, url, [])
    
    doc = Nokogiri::HTML(open(url))
        
    doc.css('table.full > tbody > tr').each_with_index do |node, idx|      
      if idx > 0
        if node.css('td')[0]['colspan'].nil? # node.css('td')[0]['colspan'] != '6' # No arrests found.
          arrest = Arrest.new
          
          td = node.css('td')[0]
          arrest.name = td.css('strong').text.strip
          arrest.address = td.inner_html.split('<br>')[1].strip
          td = node.css('td')[1]
          arrest.date = td.css('strong').text.strip.gsub(/[^[:print:]]/,' ').squeeze(' ') # process to remove non printable characters, ref: http://geek.michaelgrace.org/2010/10/remove-non-printable-characters-from-string-using-ruby-regex/
          arrest.dob = td.inner_html.split('<br>')[1].strip.gsub('dob : ','') rescue nil
          td = node.css('td')[2]
          arrest.location = td.text.strip
          td = node.css('td')[3]
          arrest.incident = td.text.strip
          td = node.css('td')[4]
          arrest.ca = td.text.strip
          td = node.css('td')[5]
          arrest.charges = td.inner_html.gsub('<br>',"\n").strip
          
          arrest_day.arrests << arrest
        end
      end      
    end
    
    return arrest_day
  end

end
