class Skill < ActiveRecord::Base


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