class ClassFeature < Feature
  belongs_to :character_class, :foreign_key => :provider_id

  def provider
    self.character_class
  end

  def api_form
    cl = self.provider
    src = cl.source
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :level => self.level,
      :source => src.slice(:id, :name, :kind),
      :character_class => cl.slice(:id, :name)
    }
  end

end
