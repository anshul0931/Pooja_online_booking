class BookingsController < ApplicationController
  before_action :set_puja, only: [:new, :create]

  def new
    @booking = Booking.new(puja_id: @pooja.id, total_price: @pooja.base_price)
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.puja_id = @pooja.id
    @booking.total_price = @pooja.base_price

    if @booking.save
      redirect_to thank_you_booking_path(@booking)
    else
      flash.now[:alert] = "Error creating booking. Please check the details."
      render :new
    end
  end

  def thank_you
    @booking = Booking.find(params[:id])
    @pooja = @booking.puja  # ✅ get puja from booking
  end

  private

  def set_puja
    @pooja = Puja.find(params[:puja_id])
  end

  def booking_params
    params.require(:booking).permit(
      :user_name, :phone, :email, :samagri_required,
      :customer_type, :status, :notes, :location,
      :address, :booking_date
    )
  end
end
