class ClassFeature < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  belongs_to :character_class

  def api_show
    char_class = self.character_class
    {
      :name => self.name,
      :level => self.level,
      :description => self.description,
      :character_class => char_class.api_form,
      :source => char_class.source.api_form
    }
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("class_features")
    src = self.character_class.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Class Feature",
      "kind" => src.kind,
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
