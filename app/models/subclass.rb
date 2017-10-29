class Subclass < ActiveRecord::Base
  belongs_to :character_class

  def api_form
    {
      name: self.name,
      id: self.id,
      description: self.description,
      features: self.features.order(:level),
      source: self.source.api_form
    }
  end

  def kind
    self.source.kind
  end

end
