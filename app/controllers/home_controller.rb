class HomeController < ApplicationController
  def index
    @pooja_types = PoojaType.all
  end
end