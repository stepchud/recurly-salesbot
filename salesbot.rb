require 'sinatra'
require 'nokogiri'
require 'json'
require 'httparty'

SLACK_ENDPOINT='https://hooks.slack.com/services/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'
RECURLY_SITE_URL='https://slackathon-sales.recurly.com'

get '/' do
  "Recurly Salesbot at your service!"
end

post '/webhook' do
  xml = Nokogiri::XML.parse request.body
  puts "GOT WEBHOOK #{xml.root.name}"
  case xml.root.name
  when "closed_invoice_notification"
    closed_invoice xml
  when 'new_dunning_event_notification'
    dunning_event xml
  else
    puts "Unhandled webhook: #{xml.root.name}"
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
  account_name = [xml.xpath('//account/first_name').text, xml.xpath('//account/last_name').text].compact.join(" ")
  account_code = xml.xpath('//account/account_code').text
  state = xml.xpath('//invoice/state').text
  prefix = state == "collected" ? "💸 💸 💸  You just got paid for" : "😭 😭 😭  Failed to collect on"
  amount = xml.xpath('//invoice/total_in_cents').text.to_f/100
  currency = xml.xpath('//invoice/currency').text

  str = <<-EOS
    #{prefix} #{invoice_link invoice_number} for #{account_link(company != "" ? company : account_name, account_code)}
    Amount: #{amount} #{currency}
  EOS

  post_webhook str
end

def dunning_event xml
  invoice_number = xml.xpath('//invoice/invoice_number').text
  company = xml.xpath('//account/company_name').text
  account_name = [xml.xpath('//account/first_name').text, xml.xpath('//account/last_name').text].compact.join(" ")
  account_code = xml.xpath('//account/account_code').text
  email = xml.xpath('//account/email').text
  phone = xml.xpath('//account/phone').text
  state = xml.xpath('//invoice/state').text
  amount = xml.xpath('//invoice/total_in_cents').text.to_f/100
  currency = xml.xpath('//invoice/currency').text
  dunning_events_count = xml.xpath('//invoice/dunning_events_count').text
  final_dunning_event = xml.xpath('//invoice/final_dunning_event').text
  final_dunning_event == 'true' ? final = 'No dunning attempts remaining.' : final = "Invoice is still in dunning."
  status = state == 'collected' ? '🤑  Successful' : '🚫 💩  Failed'

  str = <<-EOS
    #{status} dunning attempt for #{account_link(company != "" ? company : account_name, account_code)} (#{invoice_link invoice_number})
    Attempt ##{dunning_events_count} -- #{final}
    Invoice amount: #{amount} #{currency}
    Might be a good time to reach out? 📬  #{format_email email} ☎️  #{format_phone phone}
  EOS

  post_webhook str
end

def invoice_link(number)
  "<#{RECURLY_SITE_URL}/invoices/#{number}|Invoice \##{number}>"
end

def account_link(name, code)
  "<#{RECURLY_SITE_URL}/accounts/#{code}|#{name}>"
end

def format_email(email)
  "<mailto:#{email}|#{email}>"
end

def format_phone(number)
  "<tel:#{number}|#{number}>"
end
