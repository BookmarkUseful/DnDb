require 'nokogiri'
require 'open-uri'

class WebSpellBuilder

  # Specifically for the given site. Only used for sources which have
  # PDFs that can't be read by PDF-Reader.

  BASE_DOMAIN = "http://www.orcpub.com"
  BASE_URL = "http://www.orcpub.com/dungeons-and-dragons/5th-edition/spells"

  def self.get_spells
    index = Nokogiri::HTML(open(BASE_URL))
    table = index.css('div.lv-body').first
    links = table.css('a').map do |link|
      BASE_DOMAIN + link['href']
    end
    spells = links.map do |url|
      self.new_spell(url)
    end
  end

  def self.new_spell(url)
    puts "URL: #{url}"
    page = Nokogiri::HTML(open(url))
    source_id = Source.where(:name => "Player's Handbook").first.id
    content = page.css("div[itemprop='characterAttribute']").first
    lines = []
    lines << content.css("span").first.try(&:text)
    spell_body = content.css("div.spell-body").first
    lines << spell_body.css("div.m-b-10").first.try(&:text)
    lines << spell_body.css("div")[1].text
    lines << spell_body.css("div")[2].text
    lines << spell_body.css("div")[3].text
    lines << spell_body.css("div")[4].text
    lines << spell_body.css("div")[5].text
    SpellBuilder.initialize_block_parse(lines.join("\n"))
  end

end
