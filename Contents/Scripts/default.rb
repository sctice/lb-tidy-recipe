#!/usr/bin/env ruby

require 'json'

def main
  path_or_str = ARGV[0]
  text = read_optional_path(path_or_str)
  tidied = text.lines.map(&method(:convert_special_chars)).join
  spaced = tidied
    .gsub(/\n{3,}/, "\n\n")
    .gsub(/(^[A-Z][^\n]+(\n|$)){3,}/m) {|m| m.split(/\n/).join("\n\n")}
  item = { "title" => spaced }
  puts item.to_json
end

def read_optional_path(path_or_str)
  return path_or_str if !File.readable?(path_or_str)
  File.open(path_or_str, 'r').read
end

def convert_special_chars(line)
  line
    .gsub(/^\s*[-*•+]\s*/, '')
    .gsub(/\b1\/2/, '½')
    .gsub(/\b1\/3/, '⅓')
    .gsub(/\b1\/4/, '¼')
    .gsub(/\b1\/8/, '⅛')
    .gsub(/\b2\/3/, '⅔')
    .gsub(/\b3\/4/, '¾')
    .gsub(/(?<=\d|^)\s*([½⅓¼⅛⅔¾])/m, '\1')
    .gsub(/\b(?:tablespoon|tbsp)(s?)\b/i, 'Tbsp\1')
    .gsub(/\b(?:teaspoon|tsp)(s?)\b/i, 'tsp\1')
    .gsub(/\bounce(s?)/i, 'oz')
    .gsub(/\bmilliliter(s)?/i, 'ml')
    .gsub(/\b((?:Tbsp|tsp|oz|ml|in|mm)s?)\./, '\1')
    .gsub(/(\d)in/, '\1-inch')
    .gsub(/(\d+) degrees/i, '\1°')
    .gsub(/(\d+)° (F|C)\b/i, '\1°\2')
    .gsub(/°(?!C|F)/, '°F')
    .gsub(/(\d+)°F(?! \(\d+°C)/) { |m| "#{m} (#{f_to_c($1)}°C)" }
end

def f_to_c(n)
  (((n.to_f - 32) * 5) / 9).floor
end

main
