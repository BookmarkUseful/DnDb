class RaceFeature < Feature
  belongs_to :race, :foreign_key => :provider_id

  def provider
    self.race
  end

  def api_form
    race = self.provider
    source = race.source
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :level => self.level,
      :source => source.slice(:id, :name, :kind),
      :character_class => race.slice(:id, :name)
    }
  end

end
