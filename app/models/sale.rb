class Sale < ApplicationRecord
  belongs_to :arrondissement

  # Abréviations de voies utilisées par DVF.
  STREET_TYPES = {
    "AV" => "avenue", "BD" => "boulevard", "PL" => "place", "IMP" => "impasse",
    "PAS" => "passage", "VLA" => "villa", "SQ" => "square", "ALL" => "allée",
    "CHE" => "chemin", "CRS" => "cours", "QUAI" => "quai", "RUE" => "rue",
    "CITE" => "cité", "RTE" => "route", "PRT" => "porte", "HAM" => "hameau"
  }.freeze
  LOWERCASE_WORDS = %w[de du des la le les et sur aux au en à].freeze

  # "25 AV DE MARIGNY" → "25 avenue de Marigny"
  def self.format_address(raw)
    # DVF écrit "RUE D AVRON" pour "RUE D'AVRON" et "FOURS A CHAUX" pour "FOURS À CHAUX".
    cleaned = raw.to_s.gsub(/([\p{L}.]{2,}) ([DL]) (?=\p{L})/, "\\1 \\2'")
                      .gsub(/(\p{L}{2,}) A (?=\p{L})/, "\\1 à ")
    cleaned.split.map.with_index do |word, i|
      next word if word.match?(/\A\d/)
      next STREET_TYPES[word] if STREET_TYPES.key?(word)
      next word.downcase if i.positive? && LOWERCASE_WORDS.include?(word.downcase)

      formatted = capitalize_words(word)
      i.positive? ? formatted.sub(/\A([DL])'/) { "#{Regexp.last_match(1).downcase}'" } : formatted
    end.join(" ")
  end

  # "JEAN-BAPTISTE" → "Jean-Baptiste", "D'ALESIA" → "D'Alesia"
  def self.capitalize_words(word)
    word.downcase.gsub(/(\A|[-'])(\p{L})/) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).upcase}" }
  end
  private_class_method :capitalize_words
end
