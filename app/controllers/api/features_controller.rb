class Api::FeaturesController < ApplicationController
  before_action :get_feature, :only => [:show]

  # GET /api/features/(:id|:slug)
  def show
    render :json => @feature.api_form.to_json
  end

  private

  # raise error if feature not found
  def get_feature
    @feature = Feature.find_by(:id => params[:id])
    @feature ||= Feature.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @feature.nil?
  end

end
