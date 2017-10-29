class ClassFeature < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  belongs_to :character_class
  belongs_to :subclass

  def is_subclass_feature?
    self.subclass_id.present?
  end

  def is_class_feature?
    self.subclass_id.nil?
  end

  def provider_class
    if self.is_subclass_feature?
      self.subclass
    else
      self.character_class
    end
  end

  def kind
    self.provider_class.kind
  end

  def api_show
    char_class = self.character_class
    s_class = self.subclass
    {
      :name => self.name,
      :level => self.level,
      :description => self.description,
      :character_class => char_class.api_form,
      :subclass => s_class.api_form,
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
