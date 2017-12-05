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
  puts "WEBHOOK PARAMS:"
  puts params
  xml = Nokogiri::XML.parse params
  puts xml
end
