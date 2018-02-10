class Api::FeatsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_feat, :only => [:show]

  # GET /api/feats
  def index
    @feats = Feat.all.map(&:api_form)
    render :json => @feats.to_json
  end

  # GET /api/feats/:id
  def show
    render :status => 200, :json => @feat.api_form
  end

  private

  # raise error if feat not found
  def get_feat
    @feat = Feat.find_by(:id => params[:id])
    render :status => 500 if @feat.nil?
  end

  def feat_params
    params.require(:feat).permit(
      :name,
      :id,
      :description,
      :prerequisite
    )
  end

end
