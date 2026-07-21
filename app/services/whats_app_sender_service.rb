class WhatsAppSenderService
  def self.send_message(to_number, message_body)
    phone_number_id = Rails.application.credentials.dig(:whatsapp, :phone_number_id)
    access_token = Rails.application.credentials.dig(:whatsapp, :access_token)

    if phone_number_id.blank? || access_token.blank?
      Rails.logger.error("WhatsAppSenderService: Missing credentials (phone_number_id or access_token).")
      return false
    end

    url = "https://graph.facebook.com/v20.0/#{phone_number_id}/messages"

    conn = Faraday.new(url: url) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        messaging_product: "whatsapp",
        to: to_number,
        type: "text",
        text: { body: message_body }
      }
    end

    unless response.success?
      Rails.logger.error("WhatsAppSenderService Error: #{response.status} - #{response.body}")
    end

    response.success?
  rescue => e
    Rails.logger.error("WhatsAppSenderService Exception: #{e.message}")
    false
  end
end
