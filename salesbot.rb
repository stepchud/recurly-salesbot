require 'sinatra'
require 'nokogiri'
require 'json'
require 'httparty'

SLACK_ENDPOINT='https://hooks.slack.com/services/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'
INVOICES_URL='https://slackathon-sales.recurly.com/invoices/'

get '/' do
  "Recurly Salesbot at your service!"
end

get '/webhook' do
  "Hello Webhooks"
end

post '/webhook' do
  xml = Nokogiri::XML.parse request.body
  case xml.root.name
  when "closed_invoice_notification"
    closed_invoice xml
  else
    post_webhook "Received webhook: #{xml.root.name}"
  end

  content_type :json
  xml.to_json
end

private

def post_webhook message
  HTTParty.post(
    SLACK_ENDPOINT,
    headers: { 'Content-Type' => 'application/json' },
    body: { "text": message }.to_json
  )
end

def closed_invoice xml
  invoice_number = xml.xpath('//invoice/invoice_number').text
  company = xml.xpath('//account/company_name').text
  account_name = xml.xpath('//account/first_name').text + ' ' + xml.xpath('//account/last_name').text
  state = xml.xpath('//invoice/invoice_number').text
  amount = xml.xpath('//invoice/total_in_cents').text.to_f/100
  currency = xml.xpath('//invoice/currency').text.to_f/100

  str = <<~eos
  #{state.capitalize} invoice #{invoice_number} for #{company.present? ? company : name}
  Amount: #{amount} #{currency}
  eos

  post_webhook str
  # post_webhook "New Invoice! <#{INVOICES_URL}#{invoice_number}|\##{invoice_number}>"
end
