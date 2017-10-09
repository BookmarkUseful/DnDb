class Api::SourcesController < ApplicationController

  # GET /api/sources
  def index
    sources = Source.api
    response = {
      :data => sources
    }
    render :json => response.to_json
  end

end