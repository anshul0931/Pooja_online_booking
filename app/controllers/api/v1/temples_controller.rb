module Api
  module V1
    class TemplesController < BaseController
      def index
        @temples = Temple.all
        render json: @temples.map { |temple| temple_json(temple) }
      end

      def show
        @temple = Temple.find(params[:id])
        render json: temple_json(@temple)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Temple not found" }, status: :not_found
      end

      private

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
