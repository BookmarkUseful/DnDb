class SpellBuilder

  FIRST_NON_WHITESPACE_REGEX = /[^\s]/
  MULTIPLE_SPACE_REGEX = /[ ]{2,}/
  LINE_OF_DIGITS_REGEX = /^[0-9]*$/
  CHAPTER_INDICATOR_REGEX = /^chapter [0-9]/i
  MAX_TAB_LENGTH = 4

  MapSchools = {
    "abjuration" => 0,
    "conjuration" => 1,
    "divination" => 2,
    "enchantment" => 3,
    "evocation" => 4,
    "illusion" => 5,
    "necromancy" => 6,
    "transmutation" => 7
  }

  MapRange = {
    "infinite" => -1,
    "unlimited" => -1,
    "sight" => -2
  }

##############################
# PREPARE BLOCKS FOR PARSING #
##############################

  def self.build_spells(text, source_id, num_cols)
    blocks = self.build_spell_blocks(text, source_id, num_cols)
    blocks = blocks.map do |block|
      self.initialize_block_parse(block)
    end
    blocks.map do |block|
      self.compose_spell_from_block(block)
    end
  end

  def self.build_spell_blocks(text, source_id, num_cols)
    processed_text = self.process_text(page_texts, num_cols)
    self.seperate_blocks(processed_text)
  end

  def self.compose_spell_from_block(block)
    raise NotImplementedError
  end

  def self.collect_text(pdf, page_start, page_end)
    page_texts = pdf.pages[page_start..page_end].map(&:text)
    self.process_text(page_texts, num_cols)
  end

  def self.process_text(page_texts, num_cols)
    parsed_text = if num_cols == 2 then
                    page_texts.map do |page_text|
                      self.split_two_columns(page_text)
                    end.join("\n")
                  else
                    page_texts.join("\n")
                  end
    self.cleanup_text(parsed_text)
  end

  # split_two_columns assumes that there is always more than one space between
  # characters belonging to different columns. Unofrtunately right now this
  # logic only works for two columns
  def self.split_two_columns(page_text)
    num_cols = 2
    lines = page_text.split("\n")
    lines = lines.map do |line|
      if line.present? && (line =~ FIRST_NON_WHITESPACE_REGEX) <= MAX_TAB_LENGTH
        line.strip
      else
        line
      end
    end
    lines = lines.map do |line|
      # try to split according to multiple space breaks
      col_segments = []
      num_cols.times do
        col_break_index = (line =~ MULTIPLE_SPACE_REGEX)
        if col_break_index.present?
          col_segment = line[0..col_break_index]
          col_segments << col_segment
          line = line[col_break_index..-1].strip
          break if line.blank?
        else
          col_segments << line.strip
          break
        end
      end
      col_segments
    end


    # combine column segments into complete columns
    columns = []
    while lines.map(&:any?).any? do
      combined_column = lines.map(&:shift).join("\n")
      columns << combined_column
    end

    # join completed columns into one continuous column
    columns.join("\n")
  end

  def self.cleanup_text(text)
    text.split("\n").reject do |line|
      line.strip.empty? ||
        line =~ PAGE_NUMBER_REGEX ||
        line =~ CHAPTER_INDICATOR_REGEX
    end.join("\n")
  end

  def self.initialize_block_parse(block)
  	lines = block.split("\n")
                 .reject{|line| line.empty?}
                 .map(&:strip)
  	attributes = [
      :name,
      :casting_time,
      :duration,
      :school,
      :level,
      :description,
      :range,
      :concentration,
      :ritual,
      :components
    ]
  	results = {}
  	attributes.each do |attribute|
  		results[attribute] = _parse_attribute(lines, attribute)
  	end
  	results
  end

########################################
# PARSE SPECIFIC ATTRIBUTES FROM BLOCK #
########################################

  def self._parse_attribute(lines, attribute)
  	result = nil
  	if attribute == :name then
  		result = _parse_name(lines)
  	elsif attribute == :casting_time then
  		result = _parse_casting_time(lines)
  	elsif attribute == :duration then
  		result = _parse_duration(lines)
  	elsif attribute == :school then
  		result = _parse_school(lines)
  	elsif attribute == :level then
  		result = _parse_level(lines)
  	elsif attribute == :description then
  		result = _parse_description(lines)
  	elsif attribute == :range then
  		result = _parse_range(lines)
    elsif attribute == :concentration then
      result = _parse_concentration(lines)
    elsif attribute == :ritual then
      result = _parse_ritual(lines)
    elsif attribute == :components then
      result = _parse_components(lines)
  	else
  		raise "Attribute #{attribute} doesn't have a location method!"
  	end
  	raise "Attribute #{attribute} not found!" if result.nil?
  	result
  end

  def self._parse_name(lines)
    puts "PARSE NAME"
    "Name found: #{lines.first}"
  	lines.first
  end

  def self._parse_casting_time(lines)
    puts "PARSE CASTING TIME"
  	prefix = "Casting Time: "
  	casting_time_lines = lines.select{ |line| line =~ /^#{prefix}/i }
  	raise "No casting times found! Make sure to include line '#{prefix}...'" if casting_time_lines.count == 0
  	raise "Multiple casting times found! Include only one line '#{prefix}..." if casting_time_lines.count > 1
    puts "Checking line '#{casting_time_lines.first}' for casting time"
    _interpret_game_time(casting_time_lines.first[(prefix.length)..-1].strip)
  end

  def self._parse_concentration(lines)
    puts "PARSE CONCENTRATION"
    prefix = "Duration: "
  	duration_lines = lines.select{ |line| line =~ /^#{prefix}/i }
    raise "No durations found! Make sure to include line '#{prefix}...'" if duration_lines.count == 0
    raise "Multiple durations found! Include only one line '#{prefix} ..." if duration_lines.count > 1
    puts "Checking line '#{duration_lines.first}' for concentration"
    (duration_lines.first =~ /concentration/i).present?
  end

  def self._parse_ritual(lines)
    puts "PARSE RITUAL"
    # assume ritual tag is on second line
    line = lines[1].downcase
    puts "Checking line '#{line}' for ritual"
    (line =~ /ritual/i).present?
  end

  def self._parse_duration(lines)
    puts "PARSE DURATION"
  	prefix = "Duration: "
  	duration_lines = lines.select{ |line| line =~ /^#{prefix}/i }
  	raise "No durations found! Make sure to include line '#{prefix}...'" if duration_lines.count == 0
  	raise "Multiple durations found! Include only one line '#{prefix}..." if duration_lines.count > 1
    puts "Checking line '#{duration_lines.first}' for duration"
  	_interpret_game_time(duration_lines.first[(prefix.length)..-1].strip)
  end

  def self._parse_range(lines)
    puts "PARSE RANGE"
  	prefix = "Range: "
  	range_lines = lines.select{ |line| line =~ /^#{prefix}/i }
  	raise "No ranges found! Make sure to include line '#{prefix}...'" if range_lines.count == 0
  	raise "Multiple rangess found! Include only one line '#{prefix}..." if range_lines.count > 1
  	range_line = range_lines.first[(prefix.length)..-1].strip
    puts "Checking line '#{range_line}' for range"
    return 0 if range_line =~ /self/i
    return 5 if range_line =~ /touch/i
    MapRange.each do |key, val|
      puts "Checking '#{range_line.downcase}' for '#{key}'. Will assign #{val}"
      return val if range_line =~ /#{key}/i
    end
    range_line.gsub(/[^0-9]/, "").to_i
  end

  def self._parse_school(lines)
    puts "PARSE SCHOOL"
    # assumes school is on second line
    line = lines[1]
    puts "Checking line '#{line}' for school"
    # only checks for valid schools from Spell class
    schools = line.downcase.split(" ") & Spell.schools.keys
    puts "Found schools #{schools}"
    raise "No valid schools found! Make sure to include a school on the second line." if schools.count == 0
    raise "Multiple schools found! Include only one school on the second line." if schools.count > 1
    MapSchools[schools.first]
  end

  def self._parse_level(lines)
    puts "PARSE LEVEL"
    # assume level is on second lines
    line = lines[1].downcase
    puts "Checking line '#{line}' for level"
    return 0 if line.include?("cantrip")
    levels = line.split(" ").select{|word| word =~ /\d/}
    puts "Found levels #{levels}"
    raise "No valid levels found! Make sure to include a level on the second line." if levels.count == 0
    raise "Multiple levels found! Include only one level on the second line." if levels.count > 1
    levels.first.first.to_i
  end

  def self._parse_description(lines)
    puts "PARSE DESCRIPTION"
    # Remove name and level/school lines
    desc_lines = lines.drop(2).reject{|line| line =~ /^(Casting Time|Range|Components|Duration)/i}
    puts "Found #{desc_lines.count} lines of description"
    description = desc_lines.join(" ")
    raise "No description found!" if description.empty?
    description
  end

  def self._parse_components(lines)
    puts "PARSE COMPONENTS"
    prefix = "Components: "
    comp_lines = lines.select{ |line| line =~ /^#{prefix}/i }
    raise "No components found! Make sure to include line '#{prefix}...'" if comp_lines.count == 0
    raise "Multiple components found! Include only one line '#{prefix}..." if comp_lines.count > 1
    comp_line = comp_lines.first[(prefix.length)..-1].strip
    puts "Checking line '#{comp_line}' for components"
    comp_line
  end

  # returning 0 indicates instantaneous
  # returning -1 indicates a bonus action
  # returning -2 indicates a reaction
  # returning -3 indicates infinite
  # else return is time in seconds
  def self._interpret_game_time(time_string)
  	return 0 if time_string =~ /instantaneous/i
  	return -1 if time_string =~ /bonus action/i
  	return -2 if time_string =~ /reaction/i
    return -3 if time_string =~ /until dispelled/i
    return -4 if time_string =~ /special/i
  	unit = time_string.split(" ").last.chomp(".").chomp("s").downcase
  	number = time_string.delete("^0-9").to_i
    puts "Found #{number} #{unit}(s)"
  	if unit == "action" || unit == "round" then
  		return number * 6 # since each action/round is 6 seconds
  	elsif unit == "minute" then
  		return number * 60
  	elsif unit == "hour" then
  		return number * 3600
  	elsif unit == "day" then
  		return number * 86400
  	else
  		raise "Can't process time string '#{time_string}'!"
  	end
  end

=begin

  Gaea’s Hand
  1st-level conjuration

  Casting Time: 1 action
  Range: 30 feet

  Components: V, S, M (a vial of water)
  Duration: Concentration, up to 1 minute

  You conjure a makeshift arm made of weeds and branches, which
  sprouts out of a point within range. As you cast the spell, you may give
  a melee weapon to the arm for it to fight with. Otherwise, it deals 1d4
  damage on its attacks.

=end

end
