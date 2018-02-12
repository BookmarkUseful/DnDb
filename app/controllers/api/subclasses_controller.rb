class Api::SubclassesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_subclass, :only => [:show, :update]

  ##
  # GET /api/subclasses
  #
  # Returns a collection of ordered Subclasses
  #
  # Filter Params - If any not provided, no filtering for that fields occurs
  # @param {String[]} [:kinds] subset of ['core', 'supplement', 'unearthed_arcana', 'homebrew']
  # @param {Fixnum[]} [:sources] array of source ids to pull from
  # @param {Fixnum[]} [:classes] returns only subclassesbelonging to the included classes
  #
  # @return {Object[]} array of Subclass objects conforming to params including
  # surface level details on source and character classes.
  #
  def index
    sources = params[:sources].is_a?(Array) ? params[:sources].map(&:to_i) : nil
    kinds = params[:kinds].is_a?(Array) ? params[:kinds].map{ |s| Source::Kinds[s.to_sym] } : nil
    classes = params[:classes].is_a?(Array) ? params[:classes].map(&:to_i) : nil

    @subclasses = Subclass.api
    @subclasses = @subclasses.joins(:source).where(:sources => {:kind => kinds}) if kinds.present?
    @subclasses = @subclasses.joins(:source).where(:sources => {:id => sources}) if sources.present?
    @subclasses = @subclasses.joins(:character_class).where(:character_classes => {:id => classes}) if classes.present?

    @subclasses = @subclasses.map(&:api_form)

    render :json => @subclasses.to_json
  end

  # GET /api/subclasses/:id
  def show
    render :json => @subclass.api_form.to_json
  end

  # PUT /api/subclasses/:id
  def update

    # update subclass
    attributes = {
      :name => subclass_params[:name],
      :description => subclass_params[:description],
      :source_id => subclass_params[:source_id],
      :character_class_id => subclass_params[:character_class_id]
    }
    @subclass.update_attributes!(attributes)

    # update features
    features = subclass_params[:features] || []
    updatedFeatureIds = features.map{ |f| f[:id] }.compact
    # delete features not included
    @subclass.features.select { |currFeature| !updatedFeatureIds.include?(currFeature.id) }.map do |old_feature|
      puts "[update] destroying feature #{old_feature.name}"
      old_feature.destroy!
    end
    # update existing features or create new features
    features.each do |feature|
      feature[:provider_id] = @subclass.id
      if feature[:id].present?
        old_feature = SubclassFeature.find(feature[:id])
        puts "[update] Updating feature #{old_feature[:name]}"
        SubclassFeature.find(feature[:id]).update_attributes!(feature)
      else
        puts "[update] Creating new feature #{feature[:name]}"
        SubclassFeature.create!(feature)
      end
    end

    response = @subclass.reload.api_form

    render :status => 200, :json => response.to_json
  end

  # POST /api/subclasses/
  def create
    # create subclass
    attributes = {
      :name => subclass_params[:name],
      :description => subclass_params[:description],
      :character_class_id => subclass_params[:character_class_id],
      :source_id => subclass_params[:source_id]
    }
    @subclass = Subclass.create!(attributes)
    # create features
    (subclass_params[:features] || []).each do |feature|
      feature[:provider_id] = @subclass.id
      SubclassFeature.create!(feature)
    end
    render :status => 200, :json => @subclass.reload.api_form.to_json
  end

  private

  def get_subclass
    @subclass = Subclass.find_by(:id => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @subclass.nil?
  end

  def subclass_params
    params.require(:subclass).permit(
      :name,
      :id,
      :character_class_id,
      :source_id,
      :description,
      {:features => [:name, :level, :description, :id, :provider_id]},
    )
  end

end
