class Api::SpellsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_spell, :only => [:show, :update]

  # GET /api/spells
  def index
    page = params[:page].present? ? params[:page].to_i : 1
    per_page = params[:per_page].present? ? params[:per_page].to_i : 25
    pages = Spell.api.each_slice(per_page).to_a
    total = pages.length
    spells = pages[page - 1]
    spells = spells.map(&:api_form)
    response = {
      :data => spells,
      :summary => {
        :total_pages => total,
        :page => page,
        :per_page => per_page
      }
    }
    render :status => 200, :json => response.to_json
  end

  # GET /api/spells/:id
  def show
    response = @spell.api_show
    render :status => 200, :json => response.to_json
  end

  # POST /api/spells/
  def create
    fields = spell_params
    components_sorted = []
    ["V", "S", "M",].each do |comp|
      if fields[:components].include?(comp)
        components_sorted << comp
      end
    end
    fields[:components] = components_sorted.join(", ")
    fields[:character_classes] = fields[:character_classes].map do |id|
      CharacterClass.find(id)
    end if fields[:character_classes].present?

    puts fields
    @spell = Spell.create!(fields)

    if @spell
      response = { :data => @spell.reload.api_show }
      render :status => 200, :json => response.to_json
    else
      render :status => 400
    end
  end

  # PUT /api/spells/:id
  def update
    fields = spell_params
    components_sorted = []
    ["V", "S", "M",].each do |comp|
      if fields[:components].include?(comp)
        components_sorted << comp
      end
    end
    fields[:components] = components_sorted.join(", ")
    fields[:character_classes] = fields[:character_classes].map do |id|
      CharacterClass.find(id)
    end if fields[:character_classes].present?

    if @spell.update_attributes(fields)
      response = { :data => @spell.reload.api_show }
      render :status => 200, :json => response.to_json
    else
      render :status => 400
    end
  end

  private

  # raise error if spell not found
  def get_spell
    @spell = Spell.find_by(:id => params[:id])
    render :status => 500 if @spell.nil?
  end

  def spell_params
    params.require(:spell).permit(
      :name,
      :description,
      :level,
      :school,
      :casting_time,
      :source_id,
      :duration,
      :range,
      {:components => []},
      {:character_classes => []},
      :concentration,
      :ritual)
  end

end
