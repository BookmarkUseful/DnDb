class ClassFeature < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  belongs_to :character_class

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("class_features")
    src = self.character_class.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Class Feature",
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("class_features")
    loader.remove("id" => self.id)
  end

end
