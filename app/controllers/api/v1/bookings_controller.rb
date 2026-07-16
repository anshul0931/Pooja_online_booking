module Api
  module V1
    class BookingsController < BaseController
      def create
        # Find puja from params (can be nested in booking or at root level)
        puja_id = params[:puja_id] || (params[:booking] && params[:booking][:puja_id])
        
        if puja_id.blank?
          render json: { status: 'error', errors: ["puja_id is required"] }, status: :bad_request
          return
        end

        @puja = Puja.find_by(id: puja_id)
        if @puja.nil?
          render json: { status: 'error', errors: ["Puja not found"] }, status: :not_found
          return
        end

        @booking = @puja.bookings.build(booking_params)
        @booking.total_price = @puja.base_price.to_f

        if @booking.save
          render json: { status: 'success', booking: @booking }, status: :created
        else
          render json: { status: 'error', errors: @booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def booking_params
        params.require(:booking).permit(
          :user_name, :phone, :email, :gotra, :samagri_required,
          :customer_type, :status, :notes, :location,
          :address, :booking_date, :puja_id
        )
      end
    end
  end
end
