class HomeController < ApplicationController
  def index
    @pooja_types = PoojaType.all
    @pujas = Puja.all
  end
end