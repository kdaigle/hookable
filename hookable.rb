require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)
Dotenv.load

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

class HookDelivery
  include MongoMapper::Document

  key :headers, String
  key :payload, String
  timestamps!

  def pretty_headers
    JSON.pretty_generate(JSON.parse(headers))
  end

  def pretty_payload
    JSON.pretty_generate(JSON.parse(payload))
  end
end

post "/" do
  headers = {
    "X-GitHub-Event"    => request["X-GitHub-Event"],
    "X-GitHub-Delivery" => request["X-GitHub-Delivery"],
    "X-Hub-Signature"   => request["X-Hub-Signature"]
  }.to_json
  payload = request.body.read

  HookDelivery.create(
    :payload => payload,
    :headers => headers
  )

  status 200
end

get "/" do
  @hook_deliveries = HookDelivery.all
  puts @hook_deliveries.inspect
  erb :index
end

delete "/" do
  HookDelivery.destroy_all
  status 200
end
