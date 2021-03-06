class Subclass < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  before_create :set_slug
  before_save :set_slug

  ICON_DIRECTORY = "app/assets/images/subclasses/icons/"

  belongs_to :character_class
  belongs_to :source
  has_many :features, :class_name => "SubclassFeature", :foreign_key => :provider_id

  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }
  scope :api, -> { select(:id, :slug, :name, :description, :source_id, :created_at, :character_class_id) }
  scope :by_classes, -> (classes) { joins(:character_class).where(Subclass.where(:character_classes => {:slug => classes, :id => classes}).where_values.last(2).inject(:or)) }
  scope :by_sources, -> (sources) { joins(:source).where(Subclass.where(:sources => {:slug => sources, :id => sources}).where_values.last(2).inject(:or)) }

  def api_form
    {
      :name => self.name,
      :id => self.id,
      :slug => self.slug,
      :type => 'Subclass',
      :description => self.description,
      :image => self.image_url,
      :created_at => self.created_at,
      :features => self.features.select(:id, :name, :level, :description).order(:level),
      :character_class => self.character_class.slice(:id, :name, :subclass_descriptor),
      :source => self.source.slice(:id, :name, :kind),
    }
  end

  def kind
    self.source.kind
  end

  # @return [String] the snakecased filename
  def artwork_name
    "#{self.name.snakecase}.jpg"
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("default.jpg")}"
  end

  private

  def set_slug
    self.slug = self.name.to_slug
  end

  def load_into_soulmate
    loader = Soulmate::Loader.new("rule")
    src = self.source
    if src.present?
      src_info = {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    else
      src_info = {}
    end

    loader.add("term" => self.name, "id" => "#{self.id}_subclass", "data" => {
    	"id" => self.id,
    	"name" => self.name,
      "slug" => self.slug,
      "type" => "subclass",
      "kind" => src.present? ? src.kind : nil,
      "source" => src
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("rule")
    loader.remove("id" => self.id)
  end

end
