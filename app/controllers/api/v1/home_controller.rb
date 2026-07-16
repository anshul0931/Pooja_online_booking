module Api
  module V1
    class HomeController < BaseController
      def index
        @featured_pujas = Puja.limit(6)
        @temples = Temple.limit(6)

        render json: {
          featured_pujas: @featured_pujas.map { |puja| puja_json(puja) },
          temples: @temples.map { |temple| temple_json(temple) }
        }
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

      def temple_json(temple)
        {
          id: temple.id,
          name: temple.name,
          address: temple.address,
          city: temple.city,
          description: temple.description,
          image_url: temple_image_url(temple)
        }
      end
    end
  end
end
