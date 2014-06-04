class WelcomeController < ApplicationController
  def index
    @logs = Log.limit(50).order(:id).reverse_order
  end

  def mute
    Ghosty::Application.mute
    redirect_to root_path
  end

  def unmute
    Ghosty::Application.unmute
    redirect_to root_path
  end

end
