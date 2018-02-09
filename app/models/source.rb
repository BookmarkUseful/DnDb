class Source < ActiveRecord::Base

  after_create :generate_images
  after_save :load_into_soulmate
  before_destroy :remove_from_soulmate

  SOURCE_DIRECTORY = "lib/sources/"
  ARTWORK_DIRECTORY = "app/assets/images/sources/artwork/"
  ICON_DIRECTORY = "app/assets/images/sources/icons/"

  belongs_to :author
  has_many :spells
  has_many :character_classes
  has_many :items

  Kinds = {
    :core => 0,
    :supplement => 1,
    :module => 2,
    :unearthed_arcana => 3,
    :homebrew => 4
  }

  enum :kind => Kinds unless instance_methods.include? :kind

  def to_param
    permalink
  end

##########
# SCOPES #
##########

  scope :indexed, -> { where(:indexed => true) }
  scope :incomplete, -> { where(:indexed => false) }
  scope :api, -> { select(:name, :id, :page_count, :kind, :author_id) }
  scope :recent, -> { where('created_at >= ?', 2.weeks.ago) }

  def searchable?
    true
  end

  # shortened abbreviation getter
  def abbr
    self.abbreviation
  end

  def self.search(term)
    self.where('LOWER(name) LIKE :term', term: "%#{term.downcase}%")
  end

  def api_form
    {
      :name => self.name,
      :id => self.id,
      :type => 'Source',
      :author => self.author,
      :page_count => self.page_count,
      :kind => self.kind.gsub("_", " ").capitalize,
      :image => image_url("sources/artwork/#{self.artwork_name}"),
      :icon => image_url("sources/icons/#{self.artwork_name}")
    }
  end

######################
# READING SOURCE PDF #
######################

  # Sources assume that the pdf is stored in the SOURCE_DIRECTORY and
  # the filename is in snakecase with no apostrophes or quotations, with a
  # pdf extension, determined by the string.snakecase method

  # @return [String] the relative path of the source pdfs
  def filepath
    "#{SOURCE_DIRECTORY}#{self.kind.snakecase}/#{self.filename}"
  end

  # @return [String] the snakecased filename
  def filename
    "#{self.name.snakecase}.pdf"
  end

  # Sources assume that the artwork is stored in the ARTWORK_DIRECTORY and
  # the filename is in snakecase with no apostrophes or quotations, with a
  # jpg extension, determined by the string.snakecase method

  # @return [String] the relative path of the source artwork
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

  # @return [PDF::Reader] parsed source pdf
  def pdf
    filepath = self.filepath
    raise(Errno::ENOENT, filepath) unless File.exist?(filepath)
    PDF::Reader.new(filepath)
  end

  # @param  start_page [Integer] page number (from zero) from which to start
  # @param  end_page [Integer] page number (from zero) at which to end
  # @return [Array <String>] array of page contents in given page range
  def collect_text(start_page, end_page)
    self.pdf.pages[start_page..end_page].map(&:text)
  end

  # @param  start_page [Integer] page number (from zero) from which to start
  # @param  end_page [Integer] page number (from zero) at which to end
  # @param  num_cols [Integer] number of columns on pages that present spells
  # @return [Array<Spell>] unsaved spells grabbed from given page range
  # It is necessary to give the page range as its difficult to programmatically
  # determine where spells are in the book. It's easier to manually provide
  # this.
  # As the parser can't yet automatically deal with n columns, it's necessary
  # to provide this also.
  def grab_spells(start_page, end_page, num_cols)
    spell_text = self.collect_text(start_page, end_page)
    SpellBuilder.build_spells(spell_text, self, num_cols)
  end

  # uses ImageMagick to generate an icon and artwork for the PDF based on
  # the first page
  # @return [Array<String>] array of pathes to new images
  def generate_images
    icon = self.generate_icon
    artwork = self.generate_artwork
    [icon, artwork]
  end

  def generate_icon
    puts "Generating icon for #{self.name}..."
    # command line ImageMagick conversion of pdf page to image
    `convert #{self.filepath}[0] -resize 170x220 -background white -alpha remove #{self.icon_path} `
    self.icon_path
  end

  def generate_artwork
    puts "Generating artwork for #{self.name}..."
    # command line ImageMagick conversion of pdf page to image
    `convert #{self.filepath}[0] -resize 950x1100 -background white -alpha remove #{self.artwork_path}`
    self.artwork_path
  end

  def image_url(source)
    "http://localhost:3000#{ActionController::Base.helpers.image_url(source)}"
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("sources")
    loader.add("term" => self.name, "id" => self.id, "data" => {
      "kind" => self.kind,
      "type" => "Source",
    })
  end

  def remove_from_soulmate
    loader = Soulmate::Loader.new("sources")
    loader.remove("id" => self.id)
  end

end

#
#------------Schema Information------------
# id            integer (primary key)
# name          string
# page_count    integer
# kind          integer (enumerated)
# author_id     integer
# created_at    datetime
# updated_at    datetime
#
