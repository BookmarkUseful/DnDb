class Api::SkillsController < ApplicationController
  before_action :get_skill, :only => [:show]

  # GET /api/skills
  def index
    @skills = Skill.all.map(&:api_form)

    render :json => @skills.to_json
  end

  # GET /api/skills/:id
  def show
    render :json => @skill.api_form.to_json
  end

  private

  # raise error if source not found
  def get_skill
    @skill = Skill.find_by(:id => params[:id])
    render :status => 404 if @skill.nil?
  end

end
