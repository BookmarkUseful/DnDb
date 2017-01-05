class Spell < ActiveRecord::Base

  belongs_to :source
  has_and_belongs_to_many :character_classes

  SecondsInDay = 86400
  SecondsInHour = 3600
  SecondsInMinute = 60
  SecondsInRound = 6
  SecondsInAction = 6
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
    0 => "Self",
    5 => "Touch",
    -1 => "Unlimited",
    -2 => "Sight"
  }

  # Some homebrew schools have 'parent' schools.
  # Ex. Hemomancy spells (Dark Arts Player's Companion) are part of the
  # Necromancy school.
  CoreSchools = {
    :abjuration => 0,
    :conjuration => 1,
    :divination => 2,
    :enchantment => 3,
    :evocation => 4,
    :illusion => 5,
    :necromancy => 6,
    :transmutation => 7,
  }

  ### any following schools are homebrew ###
  HomebrewSchools = {
    # Hemomancy: introduced by the Dark Arts Player's Companion.
    # Sub-school of necromancy. ie any hemomancy spell is considered necromantic
    :hemomancy => 8
  }

  Schools = CoreSchools.merge(HomebrewSchools)

  # as Rails 4.2.6 doesn't have prefixed enums, gonna replicate this enum to
  # avoid duplicating enum methods.
  ParentSchools = {
    :parent_abjuration => 0,
    :parent_conjuration => 1,
    :parent_divination => 2,
    :parent_enchantment => 3,
    :parent_evocation => 4,
    :parent_illusion => 5,
    :parent_necromancy => 6,
    :parent_transmutation => 7,
    :parent_hemomancy => 8
  }

  enum school: Schools unless instance_methods.include?(:school)
  enum parent_school: ParentSchools unless instance_methods.include?(:parent_school)

  validates :name,
            :presence => true,
            :length => { :minimum => 1 }
  validates :level,
            :presence => true,
            :numericality => {
              :greater_than_or_equal_to => MIN_LEVEL,
              :less_than_or_equal_to => MAX_LEVEL
            }
  #validates_inclusion_of :school, :in => Schools.values
  #validates_inclusion_of :parent_school, :in => ParentSchools.values
  validates :casting_time,
            :presence => true
  validates :range,
            :presence => true
  validates :duration,
            :presence => true
  #validates :concentration, :presence => true
  #validates :ritual, :presence => true
  validates :description,
            :presence => true

  ##########
  # SCOPES #
  ##########

  scope :cantrip, -> { where(:level => 0) }
  scope :level, -> (n) { where(:level => n) }
  scope :core, -> { joins(:source).where('sources.kind' => Source::Kinds[:core]) }
  scope :noncore, -> { joins(:source).where('sources.kind is not ?', Source::Kinds[:core]) }
  scope :homebrew, -> { joins(:source).where('sources.kind' => Source::Kinds[:homebrew]) }

  def self.schools
    Schools.keys.map(&:to_s)
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

  def print
    name = print_name.upcase
    level_school = print_level_school
    source = print_source
    casting_time = print_casting_time
    range = print_range
    components = print_components
    duration = print_duration
    description = print_description
    [
      name,
      level_school,
      source,
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
    level_line = print_level
    school_line = print_school
    if level_line == "Cantrip" then
      return "#{school_line.titleize} #{level_line}"
    else
      return "#{level_line} #{school_line}"
    end
  end

  def print_level
    return "Cantrip" if self.level == 0
    "#{self.level.ordinalize}-level"
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
    "#{lbl}#{r} feet"
  end

  def print_components(include_label=true)
    c = self.components.to_s
    lbl = include_label ? "Components: " : nil
    lbl + c
  end

  def print_duration(include_label=true)
    d = self.duration
    lbl = include_label ? "Duration:" : nil
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
# range         integer
# source_id     integer
# created_at    datetime
# updated_at    datetime
#
