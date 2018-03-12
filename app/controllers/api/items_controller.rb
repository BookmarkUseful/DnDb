class Api::ItemsController < ApplicationController
  before_action :get_item, :only => [:show]

  # GET /api/items
  def index
    @items = Item.all
    render :json => @items.to_json
  end

  private

  # raise error if feature not found
  def get_item
    @item = Item.find_by(:id => params[:id])
    @item ||= Item.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @item.nil?
  end

end
