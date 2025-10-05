class PujasController < ApplicationController
  def index
    @pujas = Puja.all
  end

  def show
    @puja = Puja.find(params[:id])
  end
end
