class SubraceFeature < Feature
  belongs_to :subrace, :foreign_key => :provider_id

  def provider
    self.subrace
  end

  def api_form
    subrace = self.provider
    source = subrace.source
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :level => self.level,
      :source => source.slice(:id, :name, :kind),
      :character_class => subrace.slice(:id, :name)
    }
  end

end
