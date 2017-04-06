class Author < ActiveRecord::Base

  has_many :sources

  def to_param
    permalink
  end

  def searchable?
    true
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
