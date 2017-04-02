class CrystalSearchController < ApplicationController

  def index
    results = _search_model(Spell) +
              _search_model(CharacterClass) +
              _search_model(Item) +
              _search_model(Source)
    render :json => results[0..9]
  end

  def _search_model(model)
    model.search(params[:term]).pluck(:name)
  end

end
