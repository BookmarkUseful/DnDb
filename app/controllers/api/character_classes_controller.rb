class Api::CharacterClassesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_character_class, :only => [:show, :update]

  # GET /api/character_classes
  def index
    @classes = CharacterClass.all.map(&:api_form)
    render :json => @classes.to_json
  end

  # GET /api/character_classes/:id
  def show
    response = @character_class.api_form
    render :status => 200, :json => response.to_json
  end

  # PUT /api/character_classes/:id
  def update

    # update class
    class_attributes = {
      :name => character_class_params[:name],
      :summary => character_class_params[:summary],
      :description => character_class_params[:description],
      :num_starting_skills => character_class_params[:num_starting_skills],
      :hit_die => character_class_params[:hit_die]
    }
    @character_class.update_attributes!(class_attributes)

    # add/update features
    features = character_class_params[:features] || []
    updatedFeatureIds = features.map{ |f| f[:id] }.compact

    # delete features not included
    @character_class.features.select { |currFeature| !updatedFeatureIds.include?(currFeature.id) }.map do |old_feature|
      puts "[update] destroying feature #{old_feature.name}"
      old_feature.destroy!
    end
    features.each do |feature|
      feature[:provider_id] = @character_class.id
      if feature[:id].present?
        old_feature = ClassFeature.find(feature[:id])
        puts "[update] Updating feature #{old_feature[:name]}"
        ClassFeature.find(feature[:id]).update_attributes!(feature)
      else
        puts "[update] Creating new feature #{feature[:name]}"
        ClassFeature.create!(feature)
      end
    end

    response = @character_class.reload.api_form

    render :status => 200, :json => response.to_json
  end

  private

  # raise error if character class not found
  def get_character_class
    @character_class = CharacterClass.find_by(:id => params[:id])
    render :status => 500 if @character_class.nil?
  end

  def character_class_params
    params.require(:character_class).permit(
      :name,
      :id,
      :spellcasting,
      {:skills => []},
      {:saving_throws => []},
      {:features => [:name, :level, :description, :id, :character_class_id]},
      {:spells => []},
      {:armour_proficiencies => []},
      :summary,
      :description,
      :num_starting_skills,
      :hit_die
    )
  end

end
