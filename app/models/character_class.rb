class CharacterClass < ActiveRecord::Base
  after_save :load_into_soulmate
	before_destroy :remove_from_soulmate

  belongs_to :source
  has_and_belongs_to_many :spells

  IMAGE_DIR = "app/assets/character_classes/"

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }

  def searchable?
    true
  end

  def image_name
    self.name.downcase + '.jpg'
  end

  def image_path
    IMAGE_DIR + self.image_name
  end

  # Is this class a spellcaster? Ignores special subclasses that allow
  # spellcasting.
  def is_caster_by_default?
    self.spells.any?
  end

  def source_name
    self.source.name
  end

  def source_kind
    self.source.kind
  end

  def self.search(term)
    self.where('LOWER(name) LIKE :term', term: "%#{term.downcase}%")
  end

  def self.icon
    ActionController::Base.helpers.image_path("class_icon.png")
  end

  ############
  # PRINTING #
  ############

  def print_name
    self.name.titleize
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("classes")
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "link" => Rails.application.routes.url_helpers.character_class_path(self),
      "source" => self.source.abbr
      # can add icon here!
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("classes")
    loader.remove("id" => self.id)
  end

end
