class SourcesController < ApplicationController
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "sources-color"
  end

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
