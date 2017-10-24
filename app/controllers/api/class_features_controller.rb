class Api::ClassFeaturesController < ApplicationController
  before_action :get_class_feature, :only => [:show]

  # GET /api/class_features/:id
  def show
    response = {
      :data => @feature.api_show
    }
    render :json => response.to_json
  end

  private

  # raise error if spell not found
  def get_class_feature
    @feature = ClassFeature.find_by(:id => params[:id])
    render :status => 500 if @feature.nil?
  end

end