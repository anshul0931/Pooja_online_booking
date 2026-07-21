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
      4. Agar customer koi aisi pooja poochein jo upar ki list mein NAHI hai, to unhe yeh mat bolo ki 'available nahi hai' ya ignore mat karo. Iske bajay bolo: 'Yeh specific pooja hamari standard list mein nahi hai, lekin hum custom pooja bhi arrange kar sakte hain aapki zaroorat ke hisaab se. Kripya humein +91-7987488586 par call/WhatsApp karein, ya humari website ke Custom Booking page par apni requirement bhar dein, hum aapse contact karenge.'
      5. Agar customer booking karwana chahe ('mere naam se book kar do' jaisa kuch bole), to unse ek-ek karke yeh saari details maango (jo already de chuke hain wo dobara mat maango):
         - Poora naam
         - Pooja ka naam
         - Booking date (agar customer sirf din bole jaise 'date 22', to poochna kaunsa month, aur convert karna YYYY-MM-DD format mein, current date #{Date.today} ke hisaab se agar month customer na bataye to agla aane wala date maanna)
         - Phone number (10 digit)
         - Email address
         - Customer type: Indian ya NRI
         - Location/City (jaha pooja karwani hai)
         - Gotra
         
         Jab tak yeh SAAB 8 cheezein na mil jayein, BOOKING_DATA mat likhna — sirf agla missing field poochte raho, ek time pe ek hi sawaal.
         
         Jab sab mil jaye, reply ke END mein naye line mein likho:
         BOOKING_DATA: {"puja_name": "...", "customer_name": "...", "phone": "...", "email": "...", "customer_type": "Indian ya NRI", "date": "YYYY-MM-DD", "location": "...", "gotra": "..."}
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
        max_tokens: 400,
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: customer_message }
        ]
      }
    end

    if response.success?
      raw_reply = response.body.dig('choices', 0, 'message', 'content') || fallback_message("Unable to parse assistant reply.")
      process_reply_and_create_booking(raw_reply)
    else
      Rails.logger.error("Groq API Error: #{response.status} - #{response.body}")
      fallback_message("API returned an error: #{response.status}")
    end
  rescue => e
    Rails.logger.error("PoojaAssistantService Error: #{e.message}")
    fallback_message(e.message)
  end

  private

  def self.process_reply_and_create_booking(raw_reply)
    return raw_reply unless raw_reply.include?("BOOKING_DATA:")

    # Extract JSON part and clean reply
    parts = raw_reply.split("BOOKING_DATA:")
    clean_reply = parts[0].strip
    json_str = parts[1].to_s.strip

    booking_created = false
    validation_error_occurred = false

    begin
      data = JSON.parse(json_str)
      
      required_keys = %w[puja_name customer_name phone email customer_type date location gotra]
      missing_keys = required_keys.select { |k| data[k].blank? }

      if missing_keys.empty?
        puja = Puja.find_by("title LIKE ?", "%#{data['puja_name']}%")
        if puja.present?
          booking = Booking.new(
            puja_id: puja.id,
            user_name: data['customer_name'],
            phone: data['phone'],
            email: data['email'],
            customer_type: data['customer_type'],
            booking_date: data['date'],
            location: data['location'],
            gotra: data['gotra'],
            total_price: puja.base_price
          )

          if booking.save
            booking_created = true
          else
            validation_error_occurred = true
            Rails.logger.error("PoojaAssistantService Booking Validation Errors: #{booking.errors.full_messages.join(', ')}")
          end
        end
      end
    rescue JSON::ParserError => e
      Rails.logger.error("PoojaAssistantService JSON Parse Error: #{e.message}")
    rescue => e
      Rails.logger.error("PoojaAssistantService Booking Exception: #{e.message}")
    end

    if booking_created
      "#{clean_reply}\n\n✅ Aapki booking confirm ho gayi hai!"
    elsif validation_error_occurred
      "#{clean_reply}\n\nKuch details miss ho gayi lagti hain, kripya dobara try karein ya humein call karein: +91-7987488586"
    else
      clean_reply
    end
  end

  def self.fallback_message(details = "")
    "Pranam! 🙏 Kuch takneeki dikkat aa rahi hai. Kripya humare helpline number +91-7987488586 par call ya WhatsApp karein, hum aapki pooja booking mein madad karenge."
  end
end
