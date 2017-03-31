class CharacterClassesController < ApplicationController
  before_action :set_character_class, only: [:show, :edit, :update, :destroy]
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "classes-color"
  end

  def index
    @classes = CharacterClass.all
  end

  def show
    @spells = @character_class.spells.group_by{ |spell| spell.level }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character_class
      @character_class = CharacterClass.find(params[:id])
    end

end
