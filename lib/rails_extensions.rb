# contains additional methods for base classes

class String

  # Underscore a string such that camelcase, dashes and spaces are replaced by
  # underscores.
  def snakecase
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr('-', '_').
    gsub(/\s/, '_').
    gsub(/__+/, '_').
    delete("\"\'").
    downcase
  end

end
