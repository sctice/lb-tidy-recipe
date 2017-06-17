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
    .gsub(/^#*\s*(ingredients|directions):?$/i, '')
    .gsub(/\s*1\/2/, '½')
    .gsub(/\s*1\/3/, '⅓')
    .gsub(/\s*1\/4/, '¼')
    .gsub(/\s*1\/8/, '⅛')
    .gsub(/\s*2\/3/, '⅔')
    .gsub(/\s*3\/4/, '¾')
    .gsub(/(?<=\d)\s*([½⅓¼⅛⅔¾])/, '\1')
    .gsub(/\btablespoon(s?)\b/i, 'Tbsp\1')
    .gsub(/\btbsp\.?/, 'Tbsp')
    .gsub(/\bteaspoon(s?)\b/i, 'tsp\1')
    .gsub(/\bounce(s?)/i, 'oz')
    .gsub(/\bmilliliter(s)?/i, 'ml')
    .gsub(/\b(Tbsp|tsp|oz|ml|in|mm)\./, '\1')
    .gsub(/(\d)in/, '\1-inch')
    .gsub(/(\d+) degrees (F|C)?/i, '\1° \2')
    .gsub(/° (C|F)/, '°\1')
    .gsub(/°(?!C|F)/, '°F')
    .gsub(/(\d+)°F(?! \(\d+°C)/) {|m| "#{m} (#{f_to_c($1)}°C)"}
    .gsub(/^From\s+(?=http)/, '')
end

def f_to_c(n)
  (((n.to_f - 32) * 5) / 9).floor
end

main
