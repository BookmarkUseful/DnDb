class Feat < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

  belongs_to :source

  scope :api, -> { select(:name, :id, :slug, :prerequisite, :description, :created_at, :source_id) }
  scope :by_sources, -> (sources) { joins(:source).where(Feat.where(:sources => {:slug => sources, :id => sources}).where_values.last(2).inject(:or)) }

  def api_form
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :prerequisite => self.prerequisite,
      :created_at => self.created_at,
      :image => self.image_url,
      :type => 'Feat',
      :source => self.source.slice(:id, :name, :kind),
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
    loader = Soulmate::Loader.new("rule")
    src = self.source
    loader.add("term" => self.name, "id" => "#{self.id}_feat", "data" => {
    	"id" => self.id,
    	"name" => self.name,
      "slug" => self.slug,
      "type" => "feat",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("rule")
    loader.remove("id" => self.id)
  end

end

#----------------Schema-----------------#
#
# ID           Primary key
# Name         String, main identifier
# Prerequisite String
# Description  Text
# Source_id    Foreign Key, Source
#
#---------------------------------------#
