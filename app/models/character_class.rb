class CharacterClass < ActiveRecord::Base
  after_save :load_into_soulmate
	before_destroy :remove_from_soulmate

  belongs_to :source
  has_and_belongs_to_many :skills # starting proficiencies
  has_and_belongs_to_many :spells
  has_many :features, :class_name => "ClassFeature", :foreign_key => :provider_id
  has_many :subclasses

##########
# SCOPES #
##########

  scope :core, -> { joins(:sources).where('sources.core', true) }
  scope :noncore, -> { joins(:sources).where('sources.core', false) }
  scope :homebrew, -> { joins(:sources).where('sources.homebrew', true) }
  scope :api, -> { select(:id, :name, :description, :summary, :hit_die, :saving_throws, :spell_ability, :spell_slots, :features) }
  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }

  def is_caster?
    self.spells.any?
  end

  def source_name
    self.source.name
  end

  def kind
    self.source.kind
  end

  def api_form
    {
      name: self.name,
      id: self.id,
      type: 'CharacterClass',
      summary: self.summary,
      hit_die: self.hit_die,
      description: self.description,
      subclass_descriptor: self.subclass_descriptor,
      image: self.image_url,
      source: self.source.slice(:id, :name, :kind),
      features: self.features.select(:id, :name, :level, :description).order(:level),
      subclasses: self.subclasses.select(:id, :name, :description),
      spells: self.spells.select(:id, :name, :level).group_by{ |spell| spell[:level] }
    }
  end

  # @return [String] the snakecased filename
  def artwork_name
    "#{self.name.snakecase}.jpg"
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("character_classes/artwork/#{self.artwork_name}")}"
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("classes")
    src = self.source
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Character Class",
      "kind" => src.kind,
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

#
#------------Schema Information------------
# id                  primary key
# name                string
# created_at          datetime
# updated_at          datetime
# source_id           foreign key
# description         text
# long_description    text
# hit_die             integer
# saving_throws       string
# spell_ability       string
# num_starting_skills integer
# subclass_desriptor  string
#

