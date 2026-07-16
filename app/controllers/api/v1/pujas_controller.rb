module Api
  module V1
    class PujasController < BaseController
      def index
        @pujas = Puja.all
        render json: @pujas.map { |puja| puja_json(puja) }
      end

      def show
        @puja = Puja.find(params[:id])
        render json: puja_json(@puja).merge(
          ritual_deliverables: [
            "Custom Sankalp conducted with devotee's Name and Gotra.",
            "Vedic chanting and rituals performed strictly by certified pandits.",
            "Free dispatch of sacred Prasad and Energized thread to your address.",
            "Devotees can pay easily after successful completion of rituals."
          ]
        )
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Puja not found" }, status: :not_found
      end

      private

      def puja_json(puja)
        {
          id: puja.id,
          title: puja.title,
          description: puja.description,
          base_price: puja.base_price,
          duration_minutes: puja.duration_minutes,
          image_url: puja_image_url(puja)
        }
      end
    end
  end
end
