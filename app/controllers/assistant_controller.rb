class AssistantController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:ask]

  def ask
    message = params[:message]

    if message.blank?
      render json: { reply: "Pranam! Kripya apna sandesh likhein." }, status: :bad_request
      return
    end

    session[:chat_session_id] ||= SecureRandom.uuid
    chat_identifier = session[:chat_session_id]

    reply = PoojaAssistantService.get_reply(message, chat_identifier)
    render json: { reply: reply }
  end
end
