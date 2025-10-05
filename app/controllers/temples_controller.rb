class TemplesController < ApplicationController
  # Display all temples
  def index
    @temples = Temple.all
    @pooja_types = PoojaType.all  # ✅ Add this to show all pujas
  end

  # Show individual temple (optional)
  def show
    @temple = Temple.find(params[:id])
    # Optional: temple-specific pujas if you want in future
    # @pujas = @temple.pujas
  end
end
