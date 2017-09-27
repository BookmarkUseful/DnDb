class Api::AuthorsController < ApplicationController

  # GET /api/authors
  def index
    @authors = Author.all
    render :json => @authors.to_json
  end

end