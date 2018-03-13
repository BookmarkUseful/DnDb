class Feature < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

  self.inheritance_column = :type

  scope :class_features, -> { where(:type => 'ClassFeature') }
  scope :subclass_features, -> { where(:type => 'SubclassFeature') }
  scope :racial_features, -> { where(:type => 'RaceFeature') }
  scope :race_features, -> { where(:type => 'SubraceFeature') }

  def self.types
    %w(ClassFeature SubclassFeature RaceFeature SubraceFeature)
  end

  def provider
    raise "Abstract method"
  end

  private

  def set_slug
    self.slug = self.name.to_slug
  end

  def load_into_soulmate
    loader = Soulmate::Loader.new("rule")
    src = self.provider.source
    loader.add("term" => self.name, "id" => "#{self.id}_feature", "data" => {
    	"id" => self.id,
    	"name" => self.name,
      "slug" => self.slug,
      "type" => "feature",
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
