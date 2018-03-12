class Api::BackgroundsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_background, :only => [:show, :update, :delete]

  ##
  # GET /api/backgrounds
  #
  # Returns a collection of ordered Backgrounds
  #
  # Filter Params - If any not provided, no filtering for that field occurs
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {Fixnum[]} [:sources] array of source ids to pull from
  #
  # @return {Object[]} array of Background objects according to params, with limited source data
  #
  def index
    sources = params[:sources].is_a?(Array) ? params[:sources].map(&:to_i) : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil

    @backgrounds = Background.api
    @backgrounds = @backgrounds.joins(:source).where(:sources => {:kind => kinds}) if kinds.present?
    @backgrounds = @backgrounds.joins(:source).where(:sources => {:id => sources}) if sources.present?

    @backgrounds = @backgrounds.map(&:api_form)

    render :json => @backgrounds.to_json
  end

  # GET /api/backgrounds/(:id|:slug)
  def show
    render :status => 200, :json => @background.api_form.to_json
  end

  # PUT /api/backgrounds/(:id|:slug)
  def update
    fields = background_params

    if @background.update_attributes!(fields)
      render :status => 200, :json => @background.reload.api_form.to_json
    else
      render :status => 400, :json => @background.errors.messages.inspect.to_json
    end
  end

  # POST /api/background
  def create
    fields = background_params

    @background = Background.create!(fields)

    if @background
      render :status => 200, :json => @background.reload.api_form.to_json
    else
      render :status => 400, :json => @background.errors.messages.inspect.to_json
    end
  end

  private

  # raise error if background not found
  def get_background
    @background = Background.find_by(:slug => params[:id])
    @background ||= Background.find_by(:id => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @background.nil?
  end

  def background_params
    params.require(:background).permit(
      :name,
      :source_id,
      :description,
      :feature_name,
      :feature_description,
      :skill_proficiencies,
      :tool_proficiencies,
      :equipment
    )
  end

end
