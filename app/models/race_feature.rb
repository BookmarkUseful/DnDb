class RaceFeature < Feature
  belongs_to :race, :foreign_key => :provider_id

  def provider
    self.race
  end
end