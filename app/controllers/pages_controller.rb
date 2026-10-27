class PagesController < ApplicationController
  skip_before_action :authenticate_manager!

  def home
    redirect_to campaigns_path if manager_signed_in?
  end
end
