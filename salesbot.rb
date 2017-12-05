require 'sinatra'
require 'json'
require 'pp'

get '/' do
  "Recurly Salesbot at your service!"
end

get '/webhook' do
  "Hello Webhooks"
end

post '/webhook' do
  pp "WEBHOOK PARAMS:"
  pp params
end
