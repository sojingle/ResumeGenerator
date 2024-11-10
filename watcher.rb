#!/usr/bin/env ruby
require 'filewatcher'
require 'rainbow/refinement'

using Rainbow

# Files to watch for changes
WATCHED_FILES = {
  content: 'contents/*.yml',     # Content files
  template: 'template.tex.erb',  # LaTeX template
  generator: 'generate.rb',      # Generator script
  config: 'config/*.yml'         # Configuration files
}.freeze

def generate_resume
  puts "🔄 Regenerating...".yellow
  start_time = Time.now

  if system('ruby generate.rb')
    duration = (Time.now - start_time).round(2)
    puts "✅ Done in #{duration}s".green
    true
  else
    puts "❌ Error during generation".red
    false
  end
end

begin
  puts "👀 Watching for changes in:".cyan
  WATCHED_FILES.each do |type, pattern|
    puts "   #{type}: #{pattern}".cyan
  end

  Filewatcher.new(WATCHED_FILES.values).watch do |changes|
    changes.each do |path, event|
      puts "   #{event}: #{path}".black.bright
    end
    generate_resume
  end

rescue Interrupt
  puts "\n👋 Stopping watch...".yellow
  exit 0
rescue StandardError => e
  puts "❌ Error: #{e.message}".red
  exit 1
end