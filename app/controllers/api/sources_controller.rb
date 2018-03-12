class Api::SourcesController < ApplicationController
  before_action :get_source, :only => [:show]

  ##
  # GET /api/sources
  #
  # Returns a collection of ordered Sources
  #
  # Filter Params - If any not provided, no filtering for that fields occurs
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {Fixnum[]} [:sources] array of source ids to pull from
  #
  # @return {Object[]} array of Source objects conforming to params
  #
  def index
    sources = params[:sources].is_a?(Array) ? params[:sources].map(&:to_i) : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil

    @sources = Source.api
    @sources = @sources.where(:sources => {:kind => kinds}) if kinds.present?
    @sources = @sources.where(:sources => {:id => sources}) if sources.present?

    @sources = @sources.map(&:api_form)

    render :json => @sources.to_json
  end

  # GET /api/sources/(:id|:slug)
  def show
    render :json => @source.api_form.to_json
  end

  private

  # raise error if source not found
  def get_source
    @source = Source.find_by(:id => params[:id])
    @source ||= Source.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @source.nil?
  end

end
