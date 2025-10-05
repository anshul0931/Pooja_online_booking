class PoojaTypesController < ApplicationController
  def index
    @pooja_types = PoojaType.all
  end
end
