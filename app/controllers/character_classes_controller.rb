class CharacterClassesController < ApplicationController
  before_action :set_character_class, only: [:show]
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "classes-color"
  end

  def index
    @classes = CharacterClass.all
    respond_to do |format|
      format.html
      format.json { render :json => @classes.to_json }
    end
  end

  def show
    @spells = @character_class.spells.order("level").group_by{ |spell| spell.level }
    @features = @character_class.features.order("level")
    @artwork = "character_classes/#{@character_class.name.snakecase}_artwork1.png"
    if self.mobile?
      return render :formats => [:amp]
    end
    respond_to do |format|
      format.html
      format.amp
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character_class
      @character_class = CharacterClass.find_by_permalink(params[:id])
    end

end
