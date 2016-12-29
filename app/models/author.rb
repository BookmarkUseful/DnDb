class Author < ActiveRecord::Base

  has_many :sources

end

#
#------------Schema Information------------
# id            integer (primary key)
# name          string
# trusted       boolean
# created_at    datetime
# updated_at    datetime
#
