class Api::SkillsController < ApplicationController

  # GET /api/skills
  def index
    @skills = Skill.all
    render :json => @skills.to_json
  end

end