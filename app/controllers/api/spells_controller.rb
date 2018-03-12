class Api::SpellsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_spell, :only => [:show, :update]

  ##
  # GET /api/spells
  #
  # Returns a collection of ordered spells according to provided
  # parameters in the query string.
  #
  # @param {Fixnum}   [:page=1] page number, from 1.
  # @param {Fixnum}   [:per_page=25] number per page.
  #
  # Filter Params - If any not provided, no filtering for that fields occurs
  # @param {String[]} [:schools] schools for spells. Example: ['conjuration', 'abjuration']
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {Fixnum[]} [:sources] array of source ids to pull from
  # @param {Fixnum[]} [:classes] array of character class ids to pull from
  #
  # @return {Object[]} array of spell objects conforming to params including
  # surface level details on source and character classes.
  #
  def index
    page = params[:page].present? ? params[:page].to_i : 1
    page = page > 0 ? page : 1
    per_page = params[:per_page].present? ? params[:per_page].to_i : 25

    schools = params[:schools].is_a?(Array) ? params[:schools].map{ |s| Spell::Schools[s.to_sym] } : nil
    sources = params[:sources].is_a?(Array) ? params[:sources].map(&:to_i) : nil
    classes = params[:classes].is_a?(Array) ? params[:classes].map(&:to_i) : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil

    @spells = Spell.api
    @spells = @spells.where(:school => schools) if schools.present?
    @spells = @spells.joins(:source).where(:sources => {:kind => kinds}) if kinds.present?
    @spells = @spells.joins(:source).where(:sources => {:id => sources}) if sources.present?
    @spells = @spells.joins(:character_classes).where(:character_classes => {:id => classes}) if classes.present?

    pages = @spells.each_slice(per_page).to_a
    total = @spells.length
    total_pages = pages.length

    spell_page = pages[page - 1] || []

    spell_page = spell_page.map(&:api_form)

    response = {
      :data => spell_page,
      :summary => {
        :total_pages => total_pages,
        :total => total,
        :page => page,
        :per_page => per_page
      }
    }

    render :status => 200, :json => response.to_json
  end

  # GET /api/spells/(:id|:slug)
  def show
    render :status => 200, :json => @spell.api_form.to_json
  end

  # POST /api/spells
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

  # PUT /api/spells/(:id|:slug)
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
    @spell ||= Spell.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"} if @spell.nil?
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
