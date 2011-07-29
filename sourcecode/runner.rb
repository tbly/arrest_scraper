require 'rubygems'
require 'arrest_scraper'
require 'date'
require 'fakeweb'

# usage
# ruby runner.rb [-n|--number-of-days number-of-days]

n = ARGV.detect{|a| a == '-n' || a=='--number-of-days'}
n = ARGV[ARGV.index(n) + 1].to_i rescue 0

arrest_scraper = ArrestScraper.new
results = arrest_scraper.process(n,Date.today,'http://www.iowa-city.org/icgov/apps/police/blotter.asp')

# return single ArrestDay object that contains an array of Arrest objects
puts results.collect{|r| "Date: #{r.date.strftime('%m/%d/%Y')} Arrests: #{r.arrests.size}"}.join("\n")
puts "DONE"

results = arrest_scraper.process(n,Date.new(2011,7,1),'http://www.iowa-city.org/icgov/apps/police/blotter.asp')

# return single ArrestDay object that contains an array of Arrest objects
puts results.collect{|r| "Date: #{r.date.strftime('%m/%d/%Y')} Arrests: #{r.arrests.size}"}.join("\n")
puts "DONE"