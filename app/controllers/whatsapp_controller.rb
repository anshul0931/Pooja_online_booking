class WhatsappController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET /whatsapp/webhook
  def verify
    mode = params["hub.mode"]
    token = params["hub.verify_token"]
    challenge = params["hub.challenge"]

    configured_token = Rails.application.credentials.dig(:whatsapp, :verify_token)

    if mode == "subscribe" && token.present? && token == configured_token
      render plain: challenge, status: 200
    else
      render plain: "Forbidden", status: 403
    end
  end

  # POST /whatsapp/webhook
  def incoming
    message = params.dig("entry", 0, "changes", 0, "value", "messages", 0, "text", "body")
    from = params.dig("entry", 0, "changes", 0, "value", "messages", 0, "from")

    if message.present? && from.present?
      Thread.new do
        reply = PoojaAssistantService.get_reply(message)
        WhatsAppSenderService.send_message(from, reply)
      rescue => e
        Rails.logger.error("WhatsApp Controller background processing error: #{e.message}")
      end
    end

    render json: { status: "ok" }, status: 200
  end
end
