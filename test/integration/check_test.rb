1.upto(3) do |n|
`curl -X POST -H "Content-Type: application/json" -H "Accept: application/json"  -d'{"context":{"account":{"login":"marie_rose_09@yopmail.com","password":"shopelia2013"},"session":{"uuid":"#{n}129801H","callback_url":"http://127.0.0.1:3000/shopelia"},"order":{"products_urls":["http://www.amazon.fr/Les-Aristochats/dp/B002DEM97S"]}},"vendor":"Amazon"}' localhost:3000/orders`
end