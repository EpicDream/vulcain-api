class ShopeliaCallback
  
  def request url, data
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.request_uri)
    request.body = data.to_json
    request.add_field "Content-type", "application/json"
    request.add_field "Accept", "application/json"
    http.request(request)
  end
  
end
