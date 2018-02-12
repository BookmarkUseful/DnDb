class Feat < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  belongs_to :source

  scope :api, -> { select(:name, :id, :prerequisite, :description, :created_at, :source_id) }

  def api_form
    {
      :id => self.id,
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

  def load_into_soulmate
    loader = Soulmate::Loader.new("feats")
    src = self.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Feat",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("feats")
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
