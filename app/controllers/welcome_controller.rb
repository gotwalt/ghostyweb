class WelcomeController < ApplicationController
  def index
    @logs = Log.limit(50).order(:id).reverse_order
  end
end
