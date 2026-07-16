module Api
  module V1
    class CustomBookingsController < BaseController
      def create
        @custom_booking = CustomBooking.new(custom_booking_params)
        @custom_booking.status = "pending"

        if @custom_booking.save
          render json: { status: 'success', custom_booking: @custom_booking }, status: :created
        else
          render json: { status: 'error', errors: @custom_booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def custom_booking_params
        params.require(:custom_booking).permit(
          :user_name, :phone, :email, :gotra, :seva_description,
          :preferred_date, :location
        )
      end
    end
  end
end
