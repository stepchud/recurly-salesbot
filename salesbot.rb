require 'sinatra'
require 'nokogiri'
require 'json'
require 'pp'

get '/' do
  "Recurly Salesbot at your service!"
end

get '/webhook' do
  "Hello Webhooks"
end

post '/webhook' do
  xml = Nokogiri::XML.parse request.body
  puts "GOT XML"
  puts xml
  content_type :json
  xml.to_json
end
