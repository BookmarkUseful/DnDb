class ClassFeature < Feature
  belongs_to :character_class, :foreign_key => :provider_id

  def provider
    self.character_class
  end

  def api_form
    cl = self.provider
    src = cl.source
    {
      :name => self.name,
      :description => self.description,
      :level => self.level,
      :source => src.api_form,
      :character_class => cl.api_light
    }
  end

  def api_show
    cl = self.provider
    src = cl.source
    {
      :name => self.name,
      :description => self.description,
      :level => self.level,
      :source => src.api_form,
      :character_class => cl.api_light
    }
  end

end