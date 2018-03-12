# contains additional methods for base classes

class String

  # Underscore a string such that camelcase, dashes and spaces are replaced by
  # underscores.
  def snakecase
    self.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr('-', '_')
        .gsub(/\s/, '_')
        .gsub(/__+/, '_')
        .delete("\"\':")
        .downcase
  end

  def to_slug
    self.strip
        .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr('-', '_')
        .gsub(/\s/, '-')
        .gsub(/__+/, '-')
        .delete("\"\':")
        .downcase
  end
end

class Array

  def mode
    self.group_by{|i| i}.max_by{|k, v| v.count }.first
  end

end
