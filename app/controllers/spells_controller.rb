class SpellsController < ApplicationController
  before_action :set_spell, only: [:show, :amp_show]
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "spells-color"
  end

  def index
    params[:class_ids] ||= CharacterClass.pluck(:id)
    params[:levels]    ||= Spell::MIN_LEVEL..Spell::MAX_LEVEL
    params[:schools]   ||= Spell::Schools.values
    params[:sources]   ||= Source::Kinds.values
    @spells = Spell.where(:level => params[:levels],
                          :school => params[:schools])
                   .order(:level, :name)
  end

  # GET /spells/:permalink
  def show
    @artwork = "index/spell_artwork1.png"
    if self.mobile?
      return render :formats => [:amp]
    end
    respond_to do |format|
      format.html
      format.amp
    end
  end

  private
    def set_spell
      @spell = Spell.find_by_permalink(params[:id])
    end

    def spell_params
      params.require(:spell).permit(:name, :level, :school, :casting_time, :range, :duration, :description)
    end

end
