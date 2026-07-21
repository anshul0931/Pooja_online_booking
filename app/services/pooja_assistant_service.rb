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
      5. Agar customer apna naam, pooja ka naam, aur date de de aur bole 'mere naam se book kar do' ya similar, to tumhe pehle unse phone number bhi maang lena hai agar nahi diya. Jab teeno cheezein (naam, pooja, date) aur phone mil jayein, to apne reply ke bilkul END mein is exact format mein ek line add karo (customer ko yeh line nahi dikhni chahiye, isliye normal reply ke baad naye line mein likhna):
      BOOKING_DATA: {"puja_name": "<pooja ka naam>", "customer_name": "<naam>", "phone": "<number>", "date": "<YYYY-MM-DD format mein>"}
      Agar koi info missing hai, BOOKING_DATA mat likhna, pehle pooch lena missing cheez.
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

    begin
      data = JSON.parse(json_str)
      puja_name = data["puja_name"]
      customer_name = data["customer_name"]
      phone = data["phone"]
      date = data["date"]

      if puja_name.present? && customer_name.present? && phone.present? && date.present?
        puja = Puja.find_by("title LIKE ?", "%#{puja_name}%")
        if puja.present?
          Booking.create!(
            puja_id: puja.id,
            user_name: customer_name,
            phone: phone,
            booking_date: date,
            total_price: puja.base_price
          )
          booking_created = true
        end
      end
    rescue => e
      Rails.logger.error("PoojaAssistantService Booking Creation Error: #{e.message}")
    end

    if booking_created
      "#{clean_reply}\n\n✅ Aapki booking confirm ho gayi hai!"
    else
      clean_reply
    end
  end

  def self.fallback_message(details = "")
    "Pranam! 🙏 Kuch takneeki dikkat aa rahi hai. Kripya humare helpline number +91-7987488586 par call ya WhatsApp karein, hum aapki pooja booking mein madad karenge."
  end
end
