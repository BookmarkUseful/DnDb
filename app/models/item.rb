class Item < ActiveRecord::Base

  Rarities = {
    :unspecified => 0,
    :non_magical => 1,
    :common => 2,
    :uncommon => 3,
    :rare => 4,
    :very_rare => 5,
    :legendary => 6,
    :sentient => 7,
    :artifact => 8
  }

  enum :rarity => Rarities unless instance_methods.include? :rarity

  validates :name, :presence => true, :length => { :minimum => 1 }
  validates :weight, :presence => true, :numericality => { :greater_than => 0 }
  validates :value, :presence => true, :numericality => { :greater_than => 0 }

  def self.search(term)
    self.where('LOWER(name) LIKE :term', term: "%#{term.downcase}%")
  end

end
