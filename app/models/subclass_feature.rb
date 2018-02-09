class SubclassFeature < Feature
  belongs_to :subclass, :foreign_key => :provider_id

  def provider
    self.subclass
  end

  def api_form
    cl = self.provider
    src = cl.source
    {
      :name => self.name,
      :description => self.description,
      :level => self.level,
      :source => src.api_form,
      :character_class => cl.api_form
    }
  end
end
