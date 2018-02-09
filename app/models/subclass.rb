class Subclass < ActiveRecord::Base
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  ARTWORK_DIRECTORY = "app/assets/images/sublasses/artwork/"
  ICON_DIRECTORY = "app/assets/images/subclasses/icons/"

  belongs_to :character_class
  belongs_to :source
  has_many :features, :class_name => "SubclassFeature", :foreign_key => :provider_id

  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }

  def api_form
    {
      :name => self.name,
      :id => self.id,
      :type => 'Subclass',
      :description => self.description,
      :character_class => self.character_class.api_light,
      :features => self.features.order(:level),
      :source => self.source.try(:api_form),
      :image => self.image_url,
      created_at: self.created_at
    }
  end

  def kind
    self.source.kind
  end

  # @return [String] the relative path of the class artwork
  def artwork_path
    "#{ARTWORK_DIRECTORY}#{self.artwork_name}"
  end

  # @return [String] the snakecased filename
  def artwork_name
    "#{self.name.snakecase}.jpg"
  end

  def icon_path
    "#{ICON_DIRECTORY}#{self.artwork_name}"
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("default.jpg")}"
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("subclasses")
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

    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Subclass",
      "kind" => src.present? ? src.kind : nil,
      "source" => src
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("subclasses")
    loader.remove("id" => self.id)
  end

end
