class Skill < ActiveRecord::Base
  has_and_belongs_to_many :character_classes # starting skill proficiencies

  enum :ability => Dnd::Abilities unless instance_methods.include? :ability
end

#----------------Schema-----------------#
#
# ID           Primary key
# Name         String, main identifier
# Ability      Enum
# Description  Text
#
#---------------------------------------#