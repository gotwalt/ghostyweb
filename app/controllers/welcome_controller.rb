class WelcomeController < ApplicationController
  def index
    @status = Status.new

    @logs = Log.limit(50).order(:id).reverse_order
  end
end
