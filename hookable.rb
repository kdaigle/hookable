require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)
Dotenv.load unless ENV["RACK_ENV"] == "production"

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')
end

class HookDelivery
  include MongoMapper::Document

  key :payload, String
  timestamps!

  def pretty_payload
    JSON.pretty_generate(JSON.parse(payload))
  end
end

post "/" do
  request.body.rewind
  HookDelivery.create(:payload => request.body.read)
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
