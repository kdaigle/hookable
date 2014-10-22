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

  def seconds_ago
    (Time.now - created_at).to_i
  end
end
