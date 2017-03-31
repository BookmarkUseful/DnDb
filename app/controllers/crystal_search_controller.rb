class CrystalSearchController < ApplicationController

  def index
    results =
      Spell.search(params[:term]).pluck(:name) +
      CharacterClass.search(params[:term]).pluck(:name) +
      Item.search(params[:term]).pluck(:name) +
      Source.search(params[:term]).pluck(:name)
    render :json => results[0..9]
  end

end
