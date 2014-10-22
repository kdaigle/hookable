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

  def secrets_match?
    return false unless ENV["SECRET_TOKEN"]

    signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), ENV["SECRET_TOKEN"], payload)
    Rack::Utils.secure_compare(signature, headers["X-Hub-Signature"])
  end

  def headers
    JSON.parse(super)
  end

  def payload
    JSON.parse(super)
  end

  def pretty_headers
    JSON.pretty_generate(headers)
  end

  def pretty_payload
    JSON.pretty_generate(payload)
  end
end

post "/" do
  headers = {
    "X-GitHub-Event"    => request.env["X-GitHub-Event"],
    "X-GitHub-Delivery" => request.env["X-GitHub-Delivery"],
    "X-Hub-Signature"   => request.env["X-Hub-Signature"]
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
