class Author < ActiveRecord::Base

  before_create :set_slug
  before_save :set_slug

  has_many :sources

  private

  def set_slug
    self.slug = self.name.to_slug
  end

end

#
#------------Schema Information------------
# id            integer (primary key)
# name          string
# trusted       boolean
# created_at    datetime
# updated_at    datetime
#
