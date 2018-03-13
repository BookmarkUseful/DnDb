class Subrace < ActiveRecord::Base
  after_save :load_into_soulmate
	before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

	belongs_to :source
	belongs_to :race
  has_many :features, :class_name => "SubraceFeature", :foreign_key => :provider_id

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }
  scope :api, -> { select(:id, :slug, :name, :description, :source_id, :created_at) }
  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }
  scope :by_sources, -> (sources) { joins(:source).where(Subrace.where(:sources => {:slug => sources, :id => sources}).where_values.last(2).inject(:or)) }
  scope :by_race, -> (races) { joins(:race).where(Subrace.where(:race => {:slug => races, :id => races}).where_values.last(2).inject(:or)) }

	private

  def set_slug
    self.slug = self.name.to_slug
  end

  def load_into_soulmate
    loader = Soulmate::Loader.new("rule")
    src = self.source
    loader.add("term" => self.name, "id" => "#{self.id}_subrace", "data" => {
    	"id" => self.id,
    	"name" => self.name,
      "slug" => self.slug,
      "type" => "subrace",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("rule")
    loader.remove("id" => self.id)
  end

end
