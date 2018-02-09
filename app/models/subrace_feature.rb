class SubraceFeature < Feature
  belongs_to :subrace, :foreign_key => :provider_id

  def provider
    self.subrace
  end
end