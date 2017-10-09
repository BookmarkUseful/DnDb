class Api::CharacterClassesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_character_class, :only => [:show]

  # GET /character_classes
  def index
    @classes = CharacterClass.all.map(&:api_form)
    render :json => @classes.to_json
  end

  # GET /api/spells/:id
  def show
    response = {
      :data => @character_class.api_show
    }
    render :status => 200, :json => response.to_json
  end

  private

  # raise error if spell not found
  def get_character_class
    @character_class = CharacterClass.find_by(:id => params[:id])
    render :status => 500 if @character_class.nil?
  end

  def character_class_params
    params.require(:character_class)
  end

end