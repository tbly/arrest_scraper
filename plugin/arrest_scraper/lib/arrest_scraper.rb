require 'date'
require 'arrest_day'
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
    arrest_class = Struct.new(:name, :address, :date, :dob, :location, :incident, :ca, :charges, :error)
    
    begin
      doc = Nokogiri::HTML(open(url).read)
          # puts doc.content
      doc.css('table.full > tbody > tr').each_with_index do |node, idx|      
        if idx > 0
          td_elements = node.css('td') #rescue nil
          if td_elements[0]['colspan'].nil? # td_elements[0]['colspan'] != '6' # No arrests found.
            # arrest = Arrest.new            
            arrest = arrest_class.new
            begin
              td = td_elements[0]
              arrest.name = td.css('strong').text.strip
              arrest.address = td.inner_html.split('<br>')[1].strip
            rescue Exception => exc   
              arrest.error = "Error on parsing name: #{exc.message}"              
            end 
            begin
              td = td_elements[1]
              arrest.date = td.css('strong').text.strip.gsub(/[^[:print:]]/,' ').squeeze(' ') # process to remove non printable characters, ref: http://geek.michaelgrace.org/2010/10/remove-non-printable-characters-from-string-using-ruby-regex/
              arrest.dob = td.inner_html.split('<br>')[1].strip.gsub('dob : ','')
            rescue Exception => exc   
              arrest.error = "Error on parsing date/dob: #{exc.message}"              
            end 
            begin
              arrest.location = td_elements[2].text.strip
            rescue Exception => exc   
              arrest.error = "Error on parsing location: #{exc.message}"              
            end 
            begin
              arrest.incident = td_elements[3].text.strip
            rescue Exception => exc   
              arrest.error = "Error on parsing incident: #{exc.message}"              
            end 
            begin
              arrest.ca = td_elements[4].text.strip
            rescue Exception => exc   
              arrest.error = "Error on parsing incident: #{exc.message}"              
            end 
            begin
              arrest.charges = td_elements[5].inner_html.gsub('<br>',"\n").strip              
            rescue Exception => exc   
              arrest.error = "Error on parsing charges: #{exc.message}"         
            end          
            arrest_day.arrests << arrest                    
          end unless td_elements.nil?
        end      
      end
    rescue Exception => exc   
      arrest_day.error = exc.message         
    end    
    
    return arrest_day
  end

end
