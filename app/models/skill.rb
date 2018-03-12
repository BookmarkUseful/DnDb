class Skill < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

  has_and_belongs_to_many :character_classes # starting skill proficiencies

  enum :ability => Dnd::Abilities unless instance_methods.include? :ability

  def api_form
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :created_at => self.created_at,
      :image => self.image_url
    }
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("default.jpg")}"
  end

  private

  def set_slug
    self.slug = self.name.to_slug
  end

  def load_into_soulmate
    loader = Soulmate::Loader.new("skills")
    src = Source.find_by(:name => "Player's Handbook")
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "slug" => self.slug,
      "type" => "Skill",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("skills")
    loader.remove("id" => self.id)
  end
end

#----------------Schema-----------------#
#
# ID           Primary key
# Name         String, main identifier
# Ability      Enum
# Description  Text
#
#---------------------------------------#
