class CustomBookingsController < ApplicationController
  def new
    @custom_booking = CustomBooking.new
  end

  def create
    @custom_booking = CustomBooking.new(custom_booking_params)
    @custom_booking.status = "pending"

    if @custom_booking.save
      redirect_to thank_you_custom_booking_path(@custom_booking)
    else
      flash.now[:alert] = "Error submitting custom booking request. Please check details."
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    @custom_booking = CustomBooking.find(params[:id])
  end

  private

  def custom_booking_params
    params.require(:custom_booking).permit(
      :user_name, :phone, :email, :gotra, :seva_description,
      :preferred_date, :location
    )
  end
end
