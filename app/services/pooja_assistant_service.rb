class PoojaAssistantService
  API_URL = "https://api.groq.com/openai/v1/chat/completions"

  def self.get_reply(customer_message, identifier = nil)
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
      5. Agar customer booking karna chahta hai ('book kar do', 'mere naam se book karo' jaisa kuch bole), to check karo abhi tak conversation mein kya-kya details already mil chuki hain (naam, pooja, date, phone, email, customer type, location, gotra). 

         Jo bhi details missing hain, unn SABKO EK HI message mein ek sath poocho, alag-alag turn mein mat poocho. Jaise agar sirf naam pata hai, to bolo:

         'Booking confirm karne ke liye kripya yeh saari details ek sath bhej dijiye:
         1. Pooja ka naam
         2. Date (kis din karwani hai - current date #{Date.today} ke hisaab se)
         3. Phone number
         4. Email
         5. Customer type (Indian ya NRI)
         6. Location/City
         7. Gotra'

         Agar customer sab ek sath bhi de de ya thodi-thodi karke bhi de, jab bhi saari 8 cheezein (naam+pooja+date+phone+email+customer_type+location+gotra) mil jayein, turant BOOKING_DATA line likho reply ke end mein, wait mat karo confirmation ke liye — seedha book kar do aur customer ko confirm bata do.

         BOOKING_DATA: {"puja_name": "...", "customer_name": "...", "phone": "...", "email": "...", "customer_type": "...", "date": "YYYY-MM-DD", "location": "...", "gotra": "..."}
      6. Agar customer ne pehle hi kisi field ki info di hai (jaise naam ya pooja), to use dobara mat poochna, sirf missing fields poochna. Hamesha Hinglish (Roman script) mein hi reply karna, Devanagari script kabhi use mat karna.
    SYSTEM

    # Build conversation messages payload
    messages_payload = [{ role: 'system', content: system_prompt }]

    if identifier.present? && defined?(ConversationMessage)
      history_messages = ConversationMessage.where(identifier: identifier)
                                           .order(created_at: :desc)
                                           .limit(10)
                                           .reverse

      Rails.logger.info("[PoojaAssistantService] Found #{history_messages.size} previous messages for identifier: #{identifier}")

      history_messages.each do |msg|
        messages_payload << { role: msg.role, content: msg.content }
      end
    else
      Rails.logger.info("[PoojaAssistantService] No identifier provided or ConversationMessage undefined. Proceeding without history.")
    end

    # Append current user message
    messages_payload << { role: 'user', content: customer_message }

    Rails.logger.info("[PoojaAssistantService] Sending request to Groq API with #{messages_payload.size} total messages (including system prompt).")

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
        messages: messages_payload
      }
    end

    if response.success?
      raw_reply = response.body.dig('choices', 0, 'message', 'content') || fallback_message("Unable to parse assistant reply.")
      final_reply = process_reply_and_create_booking(raw_reply)

      # Save conversation history if identifier is present
      if identifier.present? && defined?(ConversationMessage)
        begin
          ConversationMessage.create(identifier: identifier, role: 'user', content: customer_message)
          ConversationMessage.create(identifier: identifier, role: 'assistant', content: final_reply)
          Rails.logger.info("[PoojaAssistantService] Saved new conversation messages to DB for identifier: #{identifier}")
        rescue => e
          Rails.logger.error("[PoojaAssistantService] Failed to save ConversationMessage: #{e.message}")
        end
      end

      final_reply
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
