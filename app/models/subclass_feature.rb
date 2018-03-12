class SubclassFeature < Feature
  belongs_to :subclass, :foreign_key => :provider_id

  def provider
    self.subclass
  end

  def api_form
    subclass = self.provider
    {
      :name => self.name,
      :id => self.id,
      :slug => self.slug,
      :description => self.description,
      :level => self.level,
      :character_class => subclass.slice(:id, :name),
      :source => subclass.source.slice(:id, :name, :kind)
    }
  end
end
