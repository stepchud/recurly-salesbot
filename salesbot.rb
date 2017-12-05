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
  xml_doc = Nokogiri::XML.parse request.body
  HTTParty.post(
    SLACK_ENDPOINT,
    headers: { 'Content-Type' => 'application/json' },
    body: { "text": "Received webhook: #{xml_doc.root.name}" }.to_json
  )

  content_type :json
  xml_doc.to_json
end
