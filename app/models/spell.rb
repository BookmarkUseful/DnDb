class Spell < ActiveRecord::Base
  after_save :load_into_soulmate
	before_destroy :remove_from_soulmate

  # TODO: Fix missing Thunderous Smite and Aura of Vitality spells in DB

  belongs_to :source
  has_and_belongs_to_many :character_classes

  SecondsInDay    = 86400
  SecondsInHour   = 3600
  SecondsInMinute = 60
  SecondsInRound  = 6
  SecondsInAction = 6
  FeetInMile      = 5280
  MIN_LEVEL = 0
  MAX_LEVEL = 9

  TimeMapping = {
    0 => "Instantaneous",
    -1 => "1 bonus action",
    -2 => "1 reaction",
    -3 => "Until dispelled",
    -4 => "Special"
  }

  RangeMapping = {
    0 =>  "Self",
    5 =>  "Touch",
    -1 => "Unlimited",
    -2 => "Sight"
  }

  Schools = {
    :abjuration => 0,
    :conjuration => 1,
    :divination => 2,
    :enchantment => 3,
    :evocation => 4,
    :illusion => 5,
    :necromancy => 6,
    :transmutation => 7,
  }

  enum school: Schools unless instance_methods.include?(:school)

  validates :name,
            :presence => true,
            :length => { :minimum => 1 }
  validates :level,
            :presence => true,
            :numericality => {
              :greater_than_or_equal_to => MIN_LEVEL,
              :less_than_or_equal_to => MAX_LEVEL
            }
  # validates_inclusion_of :school, :in => Schools.values
  validates :casting_time,
            :presence => true
  validates :range,
            :presence => true
  validates :duration,
            :presence => true
  validates :description,
            :presence => true

  ##########
  # SCOPES #
  ##########

  scope :cantrip, -> { where(:level => 0) }
  scope :level, -> (n) { where(:level => n) }
  scope :core, -> { joins(:source).where('sources.kind' => Source::Kinds[:core]) }
  scope :supplement, -> { joins(:source).where('sources.kind', Source::Kinds[:supplement]) }
  scope :unearthed_arcana, -> { joins(:source).where('sources.kind', Source::Kinds[:unearthed_arcana]) }
  scope :homebrew, -> { joins(:source).where('sources.kind' => Source::Kinds[:homebrew]) }
  scope :noncore, -> { joins(:source).where('sources.kind is not ?', Source::Kinds[:core]) }
  scope :api, -> { select(:id, :name, :level, :school, :casting_time, :range, :duration, :description, :ritual, :concentration, :components, :source_id) }
  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }

  def self.schools
    Schools.keys.map(&:to_s)
  end

  def kind
    self.source.kind
  end

  # @return [String] the snakecased filename
  def artwork_name
    "#{self.school}.png"
  end

  def image_url
    "http://localhost:3000#{ActionController::Base.helpers.image_url("spells/artwork/#{self.artwork_name}")}"
  end

  def api_form
    {
      :id => self.id,
      :name => self.name,
      :type => 'Spell',
      :level => self.level,
      :school => self.school,
      :description => self.description,
      :casting_time => self.casting_time,
      :range => self.range,
      :duration => self.duration,
      :ritual => self.ritual,
      :concentration => self.concentration,
      :components => self.components,
      :read_level => self.print_level,
      :read_casting_time => self.print_casting_time(false),
      :read_duration => self.print_duration(false),
      :image => self.image_url,
      :character_classes => self.character_classes.select(:id, :name),
      :source => self.source.slice(:id, :name, :kind),
    }
  end

  ############
  # PRINTING #
  ############

  def print
    name = print_name.upcase
    level_school = print_level_school
    casting_time = print_casting_time
    range = print_range
    components = print_components
    duration = print_duration
    description = print_description
    [
      name,
      level_school,
      "",
      casting_time,
      range,
      components,
      duration,
      "",
      description
    ].join("\n")
  end

  def print_name
    self.name
  end

  def print_level_school
    ritual = self.ritual? ? " (ritual)" : ""
    level_line = print_level
    school_line = print_school
    if level_line == "Cantrip" then
      return "#{school_line.titleize} #{level_line}#{ritual}"
    else
      return "#{level_line} #{school_line}#{ritual}"
    end
  end

  def print_level
    Spell.print_level(self.level)
  end

  def print_school
    self.school
  end

  def print_source
    self.source_name
  end

  def print_casting_time(include_label=true)
    ct = self.casting_time
    lbl = include_label ? "Casting Time: " : nil
    return "#{lbl}#{TimeMapping[ct]}" if TimeMapping[ct].present?
    if (ct % SecondsInDay == 0) && (ct / SecondsInDay > 1) then
      return "#{lbl}#{ct / SecondsInDay} days"
    elsif (ct % SecondsInHour == 0) then
      if (ct / SecondsInHour != 1) then
        return "#{lbl}#{ct / SecondsInHour} hours"
      else
        return "#{lbl}1 hour"
      end
    elsif (ct % SecondsInMinute == 0) then
      if (ct / SecondsInMinute != 1) then
        return "#{lbl}#{ct / SecondsInMinute} minutes"
      else
        return "#{lbl}1 minute"
      end
    elsif (ct % SecondsInAction == 0) then
      if (ct / SecondsInAction != 1) then
        return "#{lbl}#{ct / SecondsInAction} actions"
      else
        return "#{lbl}1 action"
      end
    else
      if ct == 1
        return "#{lbl}#{ct} second"
      else
        return "#{lbl}#{ct} seconds"
      end
    end
  end

  def print_range(include_label=true)
    r = self.range
    lbl = include_label ? "Range: " : nil
    return "#{lbl}#{RangeMapping[r]}" if RangeMapping[r].present?
    if r != 0 && r % FeetInMile == 0
      "#{lbl}#{r/FeetInMile} mile(s)"
    else
      "#{lbl}#{r} feet"
    end
  end

  def print_components(include_label=true)
    c = self.components.to_s
    lbl = include_label ? "Components: " : nil
    lbl + c
  end

  def print_duration(include_label=true)
    d = self.duration
    lbl = include_label ? "Duration:" : ""
    lbl += self.concentration? ? " Concentration, up to" : ""
    return "#{lbl} #{TimeMapping[d]}" if TimeMapping[d].present?
    if (d % SecondsInDay == 0) && (d / SecondsInDay > 1) then
      return "#{lbl} #{d / SecondsInDay} days"
    elsif (d % SecondsInHour == 0) then
      if (d / SecondsInHour != 1) then
        return "#{lbl} #{d / SecondsInHour} hours"
      else
        return "#{lbl} 1 hour"
      end
    elsif (d % SecondsInMinute == 0) then
      if (d / SecondsInMinute != 1) then
        return "#{lbl} #{d / SecondsInMinute} minutes"
      else
        return "#{lbl} 1 minute"
      end
    elsif (d % SecondsInRound == 0) then
      if (d / SecondsInRound != 1) then
        return "#{lbl} #{d / SecondsInRound} rounds"
      else
        return "#{lbl} 1 round"
      end
    else
      return "#{lbl} #{d} second(s)"
    end
  end

  def print_description
    self.description.gsub("At Higher Levels.", "\n    At Higher Levels.")
  end

  def self.print_level(level)
    return "Cantrip" if level == 0
    "#{level.ordinalize}-level"
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("spells")
    src = self.source
  	loader.add("term" => self.name, "id" => self.id, "data" => {
      "type" => "Spell",
      "kind" => src.kind,
      "source" => {
        "name" => src.name,
        "abbreviation" => src.abbr,
        "id" => src.id
      }
    })
  end

  def remove_from_soulmate
		loader = Soulmate::Loader.new("spells")
	  loader.remove("id" => self.id)
	end

end

#
#------------Schema Information------------
# id            integer (primary key)
# name          string
# description   text
# level         integer
# school        integer (enumerated)
# casting_time  integer (seconds)
# duration      integer (seconds)
# concentration boolean
# ritual        boolean
# components    string
# range         integer (enumerated)
# source_id     integer (foreign key)
# created_at    datetime
# updated_at    datetime
#
