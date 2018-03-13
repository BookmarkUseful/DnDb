class Api::SubracesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_subrace, :only => [:show, :update]

  ##
  # GET /api/subraces
  #
  # Returns a collection of ordered Subraces
  #
  # Filter Params - If any not provided, no filtering for that fields occurs
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {(Fixnum|String)[]} [:sources] array of source ids/slugs to pull from
  #
  # @return {Object[]} array of Subrace objects conforming to params including
  # surface level details on source and race.
  #
  def index
    sources = params[:sources].is_a?(Array) ? params[:sources] : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil

    @subraces = Subrace.api
    @subraces = @subraces.joins(:source).where(:sources => {:kind => kinds}) if kinds.present?
    @subraces = @subraces.by_sources(sources) if sources.present?

    @subraces = @subraces.map(&:api_form)

    render :json => @subraces.to_json
  end

  # GET /api/subraces/(:id|:slug)
  def show
    render :status => 200, :json => @subrace.api_form.to_json
  end

  # PUT /api/subraces/(:id|:slug)
  def update

    # update subrace
    subrace_attributes = {
      :name => subrace_params[:name],
      :description => subrace_params[:description],
      :source_id => subclass_params[:source_id],
      :race_id => subclass_params[:race_id]
    }
    @subrace.update_attributes!(subrace_attributes)

    # add/update features
    features = subrace_params[:features] || []
    updated_feature_ids = features.map{ |f| f[:id] }.compact

    # delete features not included
    @subrace.features.select { |curr_feature| !updated_feature_ids.include?(curr_feature.id) }.map do |old_feature|
      puts "[update] destroying feature #{old_feature.name}"
      old_feature.destroy!
    end
    features.each do |feature|
      feature[:provider_id] = @subrace.id
      if feature[:id].present?
        old_feature = SubraceFeature.find(feature[:id])
        puts "[update] Updating feature #{old_feature[:name]}"
        SubraceFeature.find(feature[:id]).update_attributes!(feature)
      else
        puts "[update] Creating new feature #{feature[:name]}"
        SubraceFeature.create!(feature)
      end
    end

    response = @subrace.reload.api_form

    render :status => 200, :json => response.to_json
  end

  private

  # raise error if subrace not found
  def get_subrace
    @subrace = Subrace.find_by(:id => params[:id])
    @subrace ||= Subrace.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @subrace.nil?
  end

  def subrace_params
    params.require(:subrace).permit(
      :name,
      :description,
      :source_id,
      :race_id,
      {:features => [:name, :description, :id, :race_id]},
    )
  end

end
