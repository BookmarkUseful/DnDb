class Api::CharacterClassesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_character_class, :only => [:show, :update]

  # GET /character_classes
  def index
    @classes = CharacterClass.all.map(&:api_form)
    render :json => @classes.to_json
  end

  # GET /api/spells/:id
  def show
    response = {
      :data => @character_class.api_show
    }
    render :status => 200, :json => response.to_json
  end

  # PUT /api/spells/:id
  def update
    puts character_class_params

    # add/update class
    class_attributes = {
      :name => character_class_params[:name],
      :description => character_class_params[:description],
      :long_description => character_class_params[:long_description],
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
      feature[:character_class_id] = @character_class.id
      if feature[:id].present?
        old_feature = ClassFeature.find(feature[:id])
        puts "[update] Updating feature #{old_feature[:name]}"
        ClassFeature.find(feature[:id]).update_attributes!(feature)
      else
        puts "[update] Creating new feature #{feature[:name]}"
        ClassFeature.create!(feature)
      end
    end
    @character_class
    
    render :status => 200, :json => @character_class.reload.api_form.to_json
  end

  private

  # raise error if spell not found
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
      :description,
      :long_description,
      :num_starting_skills,
      :hit_die
    )
  end

end