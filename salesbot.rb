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
  pp "Receiving Webhook #{params[:webhookId]}"
  pp JSON.parse(params[:result])
end
