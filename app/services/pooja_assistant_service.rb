class PoojaAssistantService
  API_URL = "https://api.groq.com/openai/v1/chat/completions"

  def self.get_reply(customer_message)
    api_key = Rails.application.credentials.dig(:groq, :api_key)

    if api_key.blank?
      return fallback_message("API key not configured.")
    end

    # Fetch live data from database
    pujas = Puja.all
    temples = Temple.all

    pujas_list = pujas.map do |p|
      "- #{p.title}: Price: Rs. #{p.base_price}, Duration: #{p.duration_minutes} minutes"
    end.join("\n")

    temples_list = temples.map do |t|
      "- #{t.name} (City: #{t.city})"
    end.join("\n")

    system_prompt = <<~SYSTEM
      You are the official AI Pooja Assistant for "Ujjain - Book My Pooja" (an online pooja booking site).
      Your goal is to answer devotee queries warmly, respectfully, and helpfully with a friendly WhatsApp-like tone (using clean Hinglish/Hindi or English as preferred by the customer).
      
      Here is the official list of Pujas offered:
      #{pujas_list}

      Here is the list of Temples:
      #{temples_list}

      CRITICAL INSTRUCTIONS:
      1. ONLY talk about and provide information about the pujas and temples listed above. Do not make up any other pujas or temples.
      2. If a customer wants to book a pooja or asks how to book, guide them to: "Pujas page pe jaake Book Now click karein" (or go to the Pujas page and click Book Now).
      3. Keep responses relatively short, polite, and respectful. Use emojis like 🕉️, 🙏, 🌸 where appropriate.
    SYSTEM

    # Faraday connection
    conn = Faraday.new(url: API_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post do |req|
      req.headers['Authorization'] = "Bearer #{api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: 'llama-3.3-70b-versatile',
        max_tokens: 300,
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: customer_message }
        ]
      }
    end

    if response.success?
      response.body.dig('choices', 0, 'message', 'content') || fallback_message("Unable to parse assistant reply.")
    else
      Rails.logger.error("Groq API Error: #{response.status} - #{response.body}")
      fallback_message("API returned an error: #{response.status}")
    end
  rescue => e
    Rails.logger.error("PoojaAssistantService Error: #{e.message}")
    fallback_message(e.message)
  end

  private

  def self.fallback_message(details = "")
    "Pranam! 🙏 Kuch takneeki dikkat aa rahi hai. Kripya humare helpline number +91-7987488586 par call ya WhatsApp karein, hum aapki pooja booking mein madad karenge."
  end
end
