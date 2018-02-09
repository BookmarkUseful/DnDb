class Api::SourcesController < ApplicationController
  before_action :get_source, :only => [:show]

  # GET /api/sources
  def index
    response = Source.all.map(&:api_form)
    render :json => response.to_json
  end

  # GET /api/sources/:id
  def show
    response = {
      :data => @source.api_form
    }
    render :json => response.to_json
  end

  private

  # raise error if source not found
  def get_source
    @source = Source.find_by(:id => params[:id])
    render :status => 500 if @source.nil?
  end

end
