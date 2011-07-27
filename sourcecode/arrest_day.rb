class ArrestDay
  attr_accessor :date, :consume_url, :arrests

  def initialize(date, consume_url, arrests = [])
    @date = date
    @consume_url = consume_url
    @arrests = arrests    
  end
  
end
