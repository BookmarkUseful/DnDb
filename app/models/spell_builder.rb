class SpellBuilder

  FIRST_NON_WHITESPACE_REGEX = /[^\s]/
  MULTIPLE_SPACE_REGEX = /[ ]{2,}/
  LINE_OF_DIGITS_REGEX = /^[0-9]*$/
  CHAPTER_INDICATOR_REGEX = /^chapter [0-9][0-9]*/i
  MAX_TAB_LENGTH = 4

  TIME_UNITS = [
    "second",
    "action",
    "round",
    "minute",
    "hour",
    "day"
  ]

  ATTRIBUTES_TO_COLLECT = [
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

##############################
# PREPARE BLOCKS FOR PARSING #
##############################

  def self.build_spells(text, source_id, num_cols)
    blocks = self.build_spell_blocks(text, source_id, num_cols)
    spells_and_attrs = blocks.map do |block|
      self.initialize_block_parse(block)
    end
    spells_and_attrs.map do |spell_attrs|
      self.compose_spell_from_attrs(spell_attrs, source_id)
    end
  end

  def self.build_spell_blocks(source_text, source_id, num_cols)
    text = self.flatten_text(source_text, num_cols)
    text = self.cleanup_text(text)
    self.seperate_blocks(text)
  end

  def self.compose_spell_from_attrs(spell_attrs, source_id)
    spell_attrs.merge!(:source_id => source_id)
    Spell.new(spell_attrs)
  end

  # blocks can be detected by relying on the school/level line, which is always
  # the second line of the spell in the books.
  # Not the best way to do this...
  def self.seperate_blocks(text)
    blocks = []
    lines = text.split("\n")
    spell_name_indices = self.find_school_level_lines(lines).map{|l| l-1}
    spell_name_indices.each_with_index do |line_index, array_index|
      start = line_index
      finish = if array_index+1 < spell_name_indices.length
                 spell_name_indices[array_index+1] - 1 # line index at end of block
               else
                 lines.length - 1 # last line index of given text
               end
      blocks << lines[start..finish].map(&:strip).join("\n")
    end
    blocks
  end

  def self.find_school_level_lines(lines)
    indices = []
    lines.each_with_index do |line, index|
      (indices << index) if self.is_school_level_line?(line)
    end
    indices
  end

  def self.is_school_level_line?(line)
    has_school = Spell.schools.map do |school|
               line =~ /#{school}/i
             end.any?
    ordinalized = (Spell::MIN_LEVEL..Spell::MAX_LEVEL).map(&:ordinalize)
    has_ordinal_level = ordinalized.map do |ord|
                      line =~ /#{ord}/i
                    end.any?
    has_cantrip = line =~ /cantrip/i
    has_level = has_ordinal_level || has_cantrip
    has_school && has_level
  end

  def self.flatten_text(page_texts, num_cols)
    flattened_pages = if num_cols == 2
                  page_texts.map do |page_text|
                    self.flatten_two_columns(page_text)
                  end
                else
                  page_texts.join("\n")
                end
    flattened_pages.join("\n")
  end

  # split_two_columns assumes that there is always more than one space between
  # characters belonging to different columns. Unfortunately right now this
  # logic only works for two columns
  def self.flatten_two_columns(page_text)
    num_cols = 2
    lines = page_text.split("\n")
    # removing tabs and indents but preserving column layout
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
        col_lengths = []
        col_break_index = (line =~ MULTIPLE_SPACE_REGEX)
        if col_break_index.present?
          start_of_next_col = line[col_break_index..-1] =~ FIRST_NON_WHITESPACE_REGEX
          col_lengths << start_of_next_col
          col_segment = line[0..col_break_index].strip
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
    # do while a column remains to be condensed
    while lines.map(&:any?).any? do
      combined_column = lines.map(&:shift).join("\n")
      columns << combined_column
    end

    # join completed columns into one continuous column
    columns.join("\n")
  end

  def self.cleanup_text(text)
    text.split("\n").reject do |line|
      line.empty? ||
        line =~ LINE_OF_DIGITS_REGEX ||
        line =~ CHAPTER_INDICATOR_REGEX
    end.join("\n")
  end

#################
# BLOCK PARSING #
#################

  def self.initialize_block_parse(block)
  	lines = block.gsub("\t", "\s").split("\n").reject{|line| line.empty?}
  	results = {}

  	ATTRIBUTES_TO_COLLECT.each do |attribute|
  		results[attribute] = _parse_attribute(lines, attribute)
  	end
  	results
  end

########################################
# PARSE SPECIFIC ATTRIBUTES FROM BLOCK #
########################################

  #TODO: Will update with more dynamic methods, removing extensive if/else
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

  # assume name is first line
  def self._parse_name(lines)
    puts "PARSE NAME"
    puts "Name found: #{lines.first}"
  	lines.first
  end

  def self._parse_casting_time(lines)
    puts "PARSE CASTING TIME"
  	prefix = "Casting Time:"
  	casting_time_lines = lines.select{ |line| line =~ /^#{prefix}/i }
  	raise "No casting times found! Make sure to include line '#{prefix}...'" if casting_time_lines.count == 0
  	raise "Multiple casting times found! Include only one line '#{prefix}..." if casting_time_lines.count != 1
    puts "Checking line '#{casting_time_lines.first}' for casting time"
    _interpret_game_time(casting_time_lines.first[(prefix.length)..-1].strip)
  end

  def self._parse_concentration(lines)
    puts "PARSE CONCENTRATION"
    prefix = "Duration:"
  	duration_lines = lines.select{ |line| line =~ /^#{prefix}/i }
    raise "No durations found! Make sure to include line '#{prefix}...'" if duration_lines.count == 0
    raise "Multiple durations found! Include only one line '#{prefix} ..." if duration_lines.count != 1
    puts "Checking line '#{duration_lines.first}' for concentration"
    conc = (duration_lines.first =~ /concentration/i).present?
    if conc
      puts "This is a concentration!"
    else
      puts "This was found to not be a concentration spell"
    end
    conc
  end

  def self._parse_ritual(lines)
    puts "PARSE RITUAL"
    # assume ritual tag is on second line
    line = lines.second
    puts "Checking line '#{line}' for ritual"
    (line =~ /ritual/i).present?
  end

  def self._parse_duration(lines)
    puts "PARSE DURATION"
  	prefix = "Duration:"
  	duration_lines = lines.select{ |line| line =~ /^#{prefix}/i }
  	raise "No durations found! Make sure to include line '#{prefix}...'" if duration_lines.count == 0
  	raise "Multiple durations found! Include only one line '#{prefix}..." if duration_lines.count != 1
    puts "Checking line '#{duration_lines.first}' for duration"
  	_interpret_game_time(duration_lines.first.remove(prefix).strip)
  end

  def self._parse_range(lines)
    puts "PARSE RANGE"
  	prefix = "Range:"
  	range_lines = lines.select{ |line| line =~ /^#{prefix}/i }
  	raise "No ranges found! Make sure to include line '#{prefix}...'" if range_lines.count == 0
  	raise "Multiple rangess found! Include only one line '#{prefix}..." if range_lines.count != 1
    range_line = range_lines.first
    puts "Checking line '#{range_line}' for range"
    Spell::RangeMapping.invert.each do |key, val|
      puts "Checking '#{range_line}' for '#{key}'. Will assign #{val}"
      return val if range_line =~ /#{key}/i
    end
    range_line.gsub(/[^0-9]/, "").to_i
  end

  def self._parse_school(lines)
    puts "PARSE SCHOOL"
    # assumes school is on second line
    line = lines.second
    puts "Checking line '#{line}' for school"
    # only checks for valid schools from Spell class
    schools = Spell.schools.select do |school|
      line =~ /#{school}/i
    end
    puts "Found schools #{schools}"
    school = if schools.size > 1
               puts "Found multiple schools. Searching for special circumstances"
               SpellBuilder._select_appropriate_school(schools)
             elsif schools.size == 1
               schools.first
             else
               raise "No school found in #{line}"
             end
    puts "Selected school #{school}"
    Spell::Schools[school.to_sym]
  end

  def self._parse_level(lines)
    puts "PARSE LEVEL"
    # assume level is on second line
    line = lines.second.downcase
    puts "Checking line '#{line}' for level"
    return 0 if line =~ /cantrip/i
    levels = line.split(" ").select{|word| word =~ /\d/}
    puts "Found levels #{levels}"
    raise "No valid levels found! Make sure to include a level on the second line." if levels.count == 0
    raise "Multiple levels found! Include only one level on the second line." if levels.count != 1
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
    prefix = "Components:"
    comp_lines = lines.select{ |line| line =~ /^#{prefix}/i }
    raise "No components found! Make sure to include line '#{prefix}...'" if comp_lines.count == 0
    raise "Multiple components found! Include only one line '#{prefix}...'" if comp_lines.count != 1
    puts "Checking line '#{comp_lines.first}' for components"
    comp_line = comp_lines.first[(prefix.length)..-1].strip
    comp_line
  end

  # returning  0 indicates instantaneous
  # returning -1 indicates a bonus action
  # returning -2 indicates a reaction
  # returning -3 indicates infinite
  # returning -4 indicates otherwise undefined
  # else return is time in seconds
  def self._interpret_game_time(time_string)
  	return 0 if time_string =~ /instantaneous/i
  	return -1 if time_string =~ /bonus action/i
  	return -2 if time_string =~ /reaction/i
    return -3 if time_string =~ /until dispelled/i
    return -4 if time_string =~ /special/i || time_string =~ /varies/i
    unit = time_string.split(" ").map do |word|
      TIME_UNITS.select do |unit|
        word =~ /#{unit}/i
      end.first
    end.compact.first
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

  def self._select_appropriate_school(schools)
    return "hemomancy" if schools.include?("hemomancy") && schools.include?("necromancy")
    raise "unable to determine appropriate school from #{schools}"
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
