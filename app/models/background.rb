class Background < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

  serialize :tool_proficiencies, Array
  serialize :equipment, Array

  belongs_to :source
  has_and_belongs_to_many :skills

  scope :api, -> {
    select(:name,
      :id,
      :slug,
      :description,
      :feature_name,
      :feature_description,
      :equipment,
      :tool_proficiencies,
      :skill_proficiencies,
      :created_at,
      :source_id) }
    scope :by_sources, -> (sources) { joins(:source).where(Background.where(:sources => {:slug => sources, :id => sources}).where_values.last(2).inject(:or)) }


  def api_form
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :feature_name => self.feature_name,
      :feature_description => self.feature_description,
      :equipment => self.equipment,
      :tool_proficiencies => self.tool_proficiencies,
      :skill_proficiencies => self.skills,
      :created_at => self.created_at,
      :image => self.image_url,
      :type => 'Background',
      :source => self.source.slice(:id, :name, :kind),
    }
  end

  def skill_proficiencies
    self.skills
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("default.jpg")}"
  end

  private

  def set_slug
    self.slug = self.name.to_slug
  end

  def load_into_soulmate
    loader = Soulmate::Loader.new("backgrounds")
    src = self.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "slug" => self.slug,
      "type" => "Background",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("backgrounds")
    loader.remove("id" => self.id)
  end

end

#----------------Schema-----------------#
#
# id                  Primary key
# name                String
# description         Text
# feature_name        String
# feature_description Text
# skill_proficiencies Text, serialized array
# tool_proficiencies  Text, serialized array
# equipment           Text, serialized array
# source_id           Foreign Key, Source
#
#---------------------------------------#
