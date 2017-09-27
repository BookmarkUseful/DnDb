class Api::ItemsController < ApplicationController

  # GET /api/items
  def index
    @items = Item.all
    render :json => @items.to_json
  end

end