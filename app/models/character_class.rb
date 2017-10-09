class CharacterClass < ActiveRecord::Base
  after_save :load_into_soulmate
	before_destroy :remove_from_soulmate

  belongs_to :source
  has_and_belongs_to_many :spells
  has_many :features, :class_name => "ClassFeature"
  has_many :subclasses

  IMAGE_DIR = "app/assets/character_classes/"

  def to_param
    permalink
  end

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }
  scope :api, -> { select(:id, :name, :description, :hit_die, :saving_throws, :spell_ability, :spell_slots, :features) }

  def searchable?
    true
  end

  def image_name
    self.name.downcase + '.jpg'
  end

  def image_path
    IMAGE_DIR + self.image_name
  end

  def is_caster?
    self.spells.any?
  end

  def source_name
    self.source.name
  end

  def source_kind
    self.source.kind
  end

  def self.search(term)
    self.where('LOWER(name) LIKE :term', :term => "%#{term.downcase}%")
  end

  def self.icon
    ActionController::Base.helpers.image_path("class_icon.png")
  end

  def api_form
    {
      name: self.name,
      id: self.id,
      description: self.description,
      long_description: self.long_description,
      spellcasting: self.is_caster?,
      features: self.features
    }
  end

  def api_show
    character_class = self.api_form
    character_class[:source] = self.source.api_form
    character_class[:spells] = self.spells.map(&:api_form).group_by{ |spell| spell[:level] }
    character_class
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
    src = self.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Character Class",
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("classes")
    loader.remove("id" => self.id)
  end

end
