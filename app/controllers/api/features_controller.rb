class Api::FeaturesController < ApplicationController
  before_action :get_feature, :only => [:show]

  # GET /api/features/:id
  def show
    response = @feature.api_form
    render :json => response.to_json
  end

  private

  # raise error if feature not found
  def get_feature
    @feature = Feature.find_by(:id => params[:id])
    render :status => 500 if @feature.nil?
  end

end
