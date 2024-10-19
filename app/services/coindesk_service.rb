class CoindeskService
  include HTTParty
  base_uri 'https://api.coindesk.com/v1/bpi/currentprice'
  
  def self.get_btc_price
    response = get('/USD.json')
    if response.success?
      response.parsed_response['bpi']['USD']['rate_float']
    else
      raise 'Error fetching BTC price'
    end
  end
end
  