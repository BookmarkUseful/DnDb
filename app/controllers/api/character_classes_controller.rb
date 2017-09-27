class Api::CharacterClassesController < ApplicationController

  # GET /character_classes
  def index
    @classes = CharacterClass.api
    render :json => @classes.to_json
  end

end