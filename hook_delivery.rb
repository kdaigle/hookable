class HookDelivery
  include MongoMapper::Document

  key :headers, String
  key :payload, String
  timestamps!

  def secrets_match?
    return false unless ENV["SECRET_TOKEN"] && headers["X-Hub-Signature"]

    signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), ENV["SECRET_TOKEN"], raw_payload)
    Rack::Utils.secure_compare(signature, headers["X-Hub-Signature"])
  end

  def headers
    JSON.parse(read_attribute(:headers))
  end

  def payload
    JSON.parse(read_attribute(:payload))
  end

  def raw_payload
    read_attribute(:payload)
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
