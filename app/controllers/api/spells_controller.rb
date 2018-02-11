class Api::SpellsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_spell, :only => [:show, :update]

  # GET /api/spells
  def index
    spells = Spell.api

    page = params[:page].present? ? params[:page].to_i : 1
    per_page = params[:per_page].present? ? params[:per_page].to_i : 25

    pages = spells.each_slice(per_page).to_a
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
    response = @spell.api_form
    render :status => 200, :json => response.to_json
  end

  # POST /api/spells/
  def create
    fields = spell_params

    if fields[:character_classes]
      fields[:character_classes] = CharacterClass.where(:id => fields[:character_classes]).select(:id)
    end

    @spell = Spell.create!(fields)

    if @spell
      render :status => 200, :json => @spell.id.to_json
    else
      render :status => 400, :json => @spell.errors.messages.inspect.to_json
    end
  end

  # PUT /api/spells/:id
  def update
    fields = spell_params

    if fields[:character_classes]
      fields[:character_classes] = CharacterClass.where(:id => fields[:character_classes]).select(:id)
    end

    if @spell.update_attributes(fields)
      render :status => 200, :json => @spell.id.to_json
    else
      render :status => 400, :json => @spell.errors.messages.inspect.to_json
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
      {:character_classes => []},
      :concentration,
      :ritual)
  end

end
