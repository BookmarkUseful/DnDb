class CharacterClassesController < ApplicationController
  before_action :set_character_class, only: [:show, :edit, :update, :destroy]

  def index
    @classes = CharacterClass.all
  end

  def show

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_character_class
      @spell = CharacterClass.find(params[:id])
    end

end
