class Api::AuthorsController < ApplicationController
  before_action :get_author, :only => [:show]

  # GET /api/authors
  def index
    @authors = Author.all
    render :json => @authors.to_json
  end

  # GET /api/authors/(:id|:slug)
  def show
    render :status => 200, :json => @author.api_form.to_json
  end

  private

  # raise error if author not found
  def get_author
    @author = Author.find_by(:id => params[:id])
    @author ||= Author.find_by(:slug => params[:id])
    render :status => 404, :json => {status: 404, message: "entity not found"}  if @author.nil?
  end

end
