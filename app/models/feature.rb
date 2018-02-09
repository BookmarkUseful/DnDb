class Feature < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

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

  def api_show
    show_form = {
      :name => self.name,
      :description => self.description,
      :type => self.type,
      :provider => self.provider.api_form
    }
    if (self.type == 'ClassFeature' || self.type == 'SubclassFeature')
      show_form[:level] = self.level
    end
    show_form
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("features")
    src = self.provider.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => self.type,
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("features")
    loader.remove("id" => self.id)
  end
end