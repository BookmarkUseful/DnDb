class Api::RacesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_race, :only => [:show, :update]

  ##
  # GET /api/races
  #
  # Returns a collection of ordered Races
  #
  # Filter Params - If any not provided, no filtering for that fields occurs
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {(Fixnum|String)[]} [:sources] array of source ids/slugs to pull from
  #
  # @return {Object[]} array of Race objects conforming to params including
  # surface level details on source and subraces.
  #
  def index
    sources = params[:sources].is_a?(Array) ? params[:sources] : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil

    @races = Race.api
    @races = @races.joins(:source).where(:sources => {:kind => kinds}) if kinds.present?
    @races = @races.by_sources(sources) if sources.present?

    @races = @races.map(&:api_form)

    render :json => @races.to_json
  end

  # GET /api/races/(:id|:slug)
  def show
    render :status => 200, :json => @race.api_form.to_json
  end

  # PUT /api/races/
  def create
    attributes = {
      :name => race_params[:name],
      :description => race_params[:description],
      :source_id => race_params[:source_id]
    }

    @race = Race.create!(attributes)

    # create features
    (race_params[:features] || []).each do |feature|
      feature[:provider_id] = @race.id
      RaceFeature.create!(feature)
    end

    render :status => 200, :json => @race.reload.api_form.to_json
  end

  # PUT /api/races/(:id|:slug)
  def update

    # update race
    race_attributes = {
      :name => race_params[:name],
      :description => race_params[:description],
      :source_id => race_params[:source_id]
    }
    @race.update_attributes!(race_attributes)

    # add/update features
    features = race_params[:features] || []
    updated_feature_ids = features.map{ |f| f[:id] }.compact

    # delete features not included
    @race.features.select { |curr_feature| !updated_feature_ids.include?(curr_feature.id) }.map do |old_feature|
      puts "[update] destroying feature #{old_feature.name}"
      old_feature.destroy!
    end
    features.each do |feature|
      feature[:provider_id] = @race.id
      if feature[:id].present?
        old_feature = RaceFeature.find(feature[:id])
        puts "[update] Updating feature #{old_feature[:name]}"
        RaceFeature.find(feature[:id]).update_attributes!(feature)
      else
        puts "[update] Creating new feature #{feature[:name]}"
        RaceFeature.create!(feature)
      end
    end

    response = @race.reload.api_form

    render :status => 200, :json => response.to_json
  end

  private

  # raise error if race not found
  def get_race
    @race = Race.find_by(:id => params[:id])
    @race ||= Race.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @race.nil?
  end

  def race_params
    params.require(:race).permit(
      :name,
      :description,
      :source_id,
      {:features => [:name, :description, :id, :race_id]},
    )
  end

end
