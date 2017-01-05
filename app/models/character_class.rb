class CharacterClass < ActiveRecord::Base

  belongs_to :source
  has_and_belongs_to_many :spells

  IMAGE_DIR = "app/assets/character_classes/"

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }

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

  ############
  # PRINTING #
  ############

  def print_name
    self.name.titleize
  end

end
