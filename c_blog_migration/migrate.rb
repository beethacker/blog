#!/usr/bin/ruby

lines = []
tags = "[]"
title = ""
description = ""
time = "1979-01-01"
REGEX = /<meta name=".*" content="(.*)"\/>/

def quote(txt) 
  return "\"#{txt}\""
end

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
    tags = "[#{extract_meta(line).split.map{|x|quote(x)}.join(", ")}]"
  end
  if line.start_with? '<meta name="description"'
   description = extract_meta(line)
  end
  if line.start_with? '<meta name="create_time"'
    time = extract_meta(line).gsub("/", "-")
  end

  if line.include? 'src="$/'
    imgSrcRegex = /src="\$\/(.*)"/
    matchResult = imgSrcRegex.match(line)
    if not matchResult.nil?
      newSrc = "src={{< resource url=\"#{matchResult[1]}\">}}"
      line = line.sub(matchResult[0], newSrc)
    end
  end

  lines << line
end

puts "---"
puts "title: #{quote(title)}"
puts "tags: #{tags}"
puts "description: #{quote(description)}"
puts "date: #{time}"
puts "---"
lines.each do |line|
  puts line
end
