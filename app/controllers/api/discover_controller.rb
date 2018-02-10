class Api::DiscoverController < ApplicationController
  protect_from_forgery with: :null_session

  DEFAULT_NUM = 5
  DISCOVERY_TYPES = [
    CharacterClass,
    Subclass,
    Spell
  ]

  # GET /api/discover
  #
  # params:
  #   num: (Integer) number of items to return [Default: DEFAULT_NUM]
  #
  def index
    num = params[:num].to_i || DEFAULT_NUM
    @items = []

    1.upto(num) do |i|
      type = DISCOVERY_TYPES.sample
      random_offset = rand(type.count)
      @items.push(type.offset(random_offset).first.api_form)
    end

    @items = @items.uniq

    render :status => 200, :json => @items.to_json
  end

  # GET /api/discover/recently_created
  #
  # params:
  #   num (Integer) number of items to return [Default: DEFAULT_NUM]
  #
  def recently_created
    num = params[:num] ? params[:num].to_i : DEFAULT_NUM

    @recent_items = []
    @items = []

    DISCOVERY_TYPES.each do |cl|
      @recent_items = @recent_items + cl.recent.limit(15)
    end

    if @recent_items.length <= num
      @items = @recent_items.map(&:api_form)
    else
      1.upto(num) do |i|
        d = rand(@recent_items.length)
        @items << @recent_items[d].api_form
        @recent_items.delete_at(d)
      end
    end

    render :status => 200, :json => @items.to_json
  end

end
