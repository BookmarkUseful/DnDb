class CharacterClass < ActiveRecord::Base

  belongs_to :source
  has_and_belongs_to_many :spells

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }

end
