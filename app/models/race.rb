class Race < ActiveRecord::Base
  after_save :load_into_soulmate
	before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

	belongs_to :source
	has_many :subraces
  has_many :features, :class_name => "RaceFeature", :foreign_key => :provider_id

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }
  scope :api, -> { select(:id, :slug, :name, :description, :source_id, :created_at) }
  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }
  scope :by_sources, -> (sources) { joins(:source).where(Race.where(:sources => {:slug => sources, :id => sources}).where_values.last(2).inject(:or)) }

  def api_form
  	puts self.subraces
    {
      :id => self.id,
      :slug => self.slug,
      :name => self.name,
      :description => self.description,
      :created_at => self.created_at,
      :image => self.image_url,
      :type => 'Race',
      :features => self.features.select(:id, :name, :description).order(:name),
      :subraces => self.subraces.select(:id, :name, :description).order(:name),
      :source => self.source.slice(:id, :name, :kind),
    }
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("default.jpg")}"
  end

	private

  def set_slug
    self.slug = self.name.to_slug
  end

  def load_into_soulmate
    loader = Soulmate::Loader.new("races")
    src = self.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "slug" => self.slug,
      "type" => "Race",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("races")
    loader.remove("id" => self.id)
  end

end
