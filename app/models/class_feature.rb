class ClassFeature < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  belongs_to :character_class

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("class_features")
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "link" => Rails.application.routes.url_helpers.character_class_path(self.character_class),
      "source" => self.character_class.source.abbr
      # can add icon here!
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("class_features")
    loader.remove("id" => self.id)
  end

end
