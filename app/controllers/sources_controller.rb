class SourcesController < ApplicationController
  before_action :set_source, only: [:show]
  before_action :set_icon_color

  def set_icon_color
    @icon_color = "sources-color"
  end

  def index
    @sources = Source.order(:kind)
    @new_sources = Dir.entries(Source::SOURCE_DIRECTORY).select do |filename|
      filename.end_with?(".pdf")
    end
  end

  private

    def set_source
      @source = Source.find_by_permalink(params[:id])
    end

end
