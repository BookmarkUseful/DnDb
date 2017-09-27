class Api::SourcesController < ApplicationController

  # GET /api/sources
  def index
    @sources = Source.all
    render :json => @sources.to_json
  end

end