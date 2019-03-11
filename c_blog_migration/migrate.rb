#!/usr/bin/ruby

lines = []
tags = "[]"
title = ""
description = ""
time = "1979-01-01"
REGEX = /<meta name=".*" content="(.*)"\/>/

def extract_meta(line)
  matching = REGEX.match(line)
  if not matching.nil?
    return matching[1]
  end
  raise "Regex failed to match!"
end

IO.readlines(ARGV[0]).each do |line|

  if line.start_with? '<meta name="title"'
    title = extract_meta(line)
  end
  if line.start_with? '<meta name="tags"'
    tags = "[#{extract_meta(line).split.join(", ")}]"
  end
  if line.start_with? '<meta name="description"'
   description = extract_meta(line)
  end
  if line.start_with? '<meta name="create_time"'
    time = extract_meta(line).gsub("/", "-")
  end

  lines << line
end

puts "---"
puts "title: #{title}"
puts "tags: #{tags}"
puts "description: #{description}"
puts "date: #{time}"
puts "---"
lines.each do |line|
  puts line
end
