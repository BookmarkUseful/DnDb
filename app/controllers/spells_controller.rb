class SpellsController < ApplicationController
  before_action :set_spell, only: [:show, :edit, :update, :destroy]
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "spells-color"
  end

  def index
    params[:class_ids] ||= CharacterClass.pluck(:id)
    params[:levels] ||= Spell::MIN_LEVEL..Spell::MAX_LEVEL
    params[:schools] ||= Spell::Schools.values
    params[:sources] ||= Source::Kinds.values
    @spells = Spell.where(:level => params[:levels],
                          :school => params[:schools])
                   .order(:level, :name)
  end

  # GET /spells/1
  # GET /spells/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_spell
      @spell = Spell.find_by_permalink(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def spell_params
      params.require(:spell).permit(:name, :level, :school, :casting_time, :range, :duration, :description)
    end

end
