class WelcomeController < ApplicationController
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "welcome-color"
  end

  def index

  end
end
