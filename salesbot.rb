require 'sinatra'
require 'nokogiri'
require 'json'
require 'httparty'

SLACK_ENDPOINT='https://hooks.slack.com/services/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'

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
  HTTParty.post(
    SLACK_ENDPOINT,
    headers: { 'Content-Type' => 'application/json' },
    body: { "text": "This is a line of text.\nAnd this is another one." }.to_json
  )

  content_type :json
  xml.to_json
end
