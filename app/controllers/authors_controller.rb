class AuthorsController < ApplicationController
  before_action :set_author, only: [:show]

  def show
  end

  def destroy
    @author.destroy
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find_by_permalink(params[:id])
    end

end
