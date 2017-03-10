class SourcesController < ApplicationController

  def index
    @sources = Source.all
    @new_sources = Dir.entries(Source::SOURCE_DIRECTORY).select do |filename|
      filename.end_with?(".pdf")
    end
  end

  def new
    @authors = Author.all
    @source = Source.new
  end



end
