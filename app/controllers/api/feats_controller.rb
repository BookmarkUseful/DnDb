class Api::FeatsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_feat, :only => [:show, :update, :delete]

  ##
  # GET /api/feats
  #
  # Returns a collection of ordered Feats
  #
  # Filter Params - If any not provided, no filtering for that fields occurs
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {(Fixnum|String)[]} [:sources] array of source ids/slugs to pull from
  # @param {Boolean} [:prerequisite] filters by presence of prerequisite
  #
  # @return {Object[]} array of Feat objects according to params, with limited source data
  #
  def index
    prerequisite = params[:prerequisite].present? ? params[:prerequisite] == "true" : nil
    sources = params[:sources].is_a?(Array) ? params[:sources] : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil

    @feats = Feat.api
    @feats = @feats.joins(:source).where(:sources => {:kind => kinds}) if kinds.present?
    @feats = @feats.by_sources(sources) if sources.present?

    if !prerequisite.nil?
      @feats = prerequisite ? @feats.where.not(:prerequisite => nil) : @feats = @feats.where(:prerequisite => nil)
    end

    @feats = @feats.map(&:api_form)

    render :json => @feats.to_json
  end

  # GET /api/feats/(:id|:slug)
  def show
    render :status => 200, :json => @feat.api_form.to_json
  end

  # PUT /api/feats/(:id|:slug)
  def update
    fields = feat_params

    if @feat.update_attributes!(fields)
      render :status => 200, :json => @feat.reload.api_form.to_json
    else
      render :status => 400, :json => @feat.errors.messages.inspect.to_json
    end
  end

  # POST /api/feats
  def create
    fields = feat_params

    @feat = Feat.create!(fields)

    if @feat
      render :status => 200, :json => @feat.reload.api_form.to_json
    else
      render :status => 400, :json => @feat.errors.messages.inspect.to_json
    end
  end

  private

  # raise error if feat not found
  def get_feat
    @feat = Feat.find_by(:id => params[:id])
    @feat ||= Feat.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @feat.nil?
  end

  def feat_params
    params.require(:feat).permit(
      :name,
      :source_id,
      :description,
      :prerequisite
    )
  end

end
