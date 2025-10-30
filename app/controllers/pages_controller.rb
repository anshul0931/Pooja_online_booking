class PagesController < ApplicationController
  def about
    # Ye khali chhod do, Rails automatically app/views/pages/about.html.erb render karega
  end
   def services
    # Rails automatically renders app/views/pages/services.html.erb
  end
  def contact; end
end
