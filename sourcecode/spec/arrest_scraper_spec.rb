require File.dirname(__FILE__) + '/../arrest_scraper.rb'

describe ArrestScraper do
  before :each do
    @arrest_scraper = ArrestScraper.new
  end
  
  it "should initially have default params as Today and no look back" do
    @arrest_scraper.date.should == Date.today
    @arrest_scraper.number_of_days.should == 0
  end
  
  it "should process with default params as Today and no look back if no arguments passed" do
    @arrest_scraper.process
    @arrest_scraper.date.should == Date.today
    @arrest_scraper.number_of_days.should == 0
  end
  
  it "should create a single ArrestDay object that contains an array of Arrest objects" do
    results = @arrest_scraper.process(0,Date.new(2011,7,1),'http://www.iowa-city.org/icgov/apps/police/blotter.asp')
    
    results.size.should == 1
    first_result = results.first
    first_result.class.should == ArrestDay
    first_result.date.should == Date.new(2011,7,1)
    first_result.consume_url.should == 'http://www.iowa-city.org/icgov/apps/police/blotter.asp?date=07012011'
    first_result.arrests.class.should == Array
    
    first_result.arrests.size.should == 14    
    first_result_arrest = first_result.arrests.first
    first_result_arrest.class.should == Arrest
    first_result_arrest.name.should == 'BRADFORD, RALEEN LYNETTE'
    first_result_arrest.address.should == '1820 HOLLYWOOD CT'
    first_result_arrest.date.should == '7/1/2011 16:25'
    first_result_arrest.dob.should == '1/21/1982'
    first_result_arrest.location.should == '1800 LAKESIDE DR'
    first_result_arrest.incident.should == '11020031'
    first_result_arrest.ca.should == 'C'
    first_result_arrest.charges.should == '1) Drive while license under suspension/cancelled'
  end
  
  it "should process the arrests for today and n preceding days if provided" do
    results = @arrest_scraper.process(3)
    @arrest_scraper.date.should == Date.today
    @arrest_scraper.number_of_days.should == 3
        
    results.size.should == 4
    results[0].date.should == Date.today
    results[1].date.should == Date.today - 1
    results[2].date.should == Date.today - 2
    results[3].date.should == Date.today - 3
  end
  
end
