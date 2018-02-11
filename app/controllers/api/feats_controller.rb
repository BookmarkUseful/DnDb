class Api::FeatsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :get_feat, :only => [:show, :update, :delete]

  # GET /api/feats
  def index
    @feats = Feat.all.map(&:api_form)
    render :json => @feats.to_json
  end

  # GET /api/feats/:id
  def show
    render :status => 200, :json => @feat.api_form
  end

  # PUT /api/feats/:id
  def update
    fields = feat_params

    if @feat.update_attributes!(fields)
      render :status => 200, :json => @feat.reload.api_form.to_json
    else
      render :status => 400, :json => @feat.errors.messages.inspect.to_json
    end
  end

  # POST /api/feats
  def create
    fields = feat_params

    puts fields

    @feat = Feat.create!(fields)

    if @feat
      render :status => 200, :json => @feat.reload.api_form.to_json
    else
      render :status => 400, :json => @feat.errors.messages.inspect.to_json
    end
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
      :source_id,
      :description,
      :prerequisite
    )
  end

end
