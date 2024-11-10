#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'config'
require 'rainbow/refinement'
require_relative 'string_extensions'
require_relative 'latex_helpers'

using Rainbow

# Directory constants relative to script location
BUILD_DIR = File.join(__dir__, 'build')
CONFIG_DIR = File.join(__dir__, 'config')
OUTPUT_DIR = File.join(__dir__, 'output')
CONTENTS_DIR = File.join(__dir__, 'contents')
TEX_DIR_NAME = 'tex'
PDF_DIR_NAME = 'pdf'

include LatexHelpers

def ensure_output_directories(content_name)
  output_dir = File.join(OUTPUT_DIR, content_name)
  tex_dir = File.join(output_dir, TEX_DIR_NAME)
  pdf_dir = File.join(output_dir, PDF_DIR_NAME)

  [OUTPUT_DIR, output_dir, tex_dir, pdf_dir].each do |dir|
    Dir.mkdir(dir) unless Dir.exist?(dir)
  end

  [tex_dir, pdf_dir]
end

def generate_pdf(tex_file, pdf_dir)
  command = [
    "pdflatex",
    "-interaction nonstopmode",
    "-aux-directory \"#{BUILD_DIR}\"",
    "-output-directory \"#{pdf_dir}\"",
    "\"#{tex_file}\""
  ].join(' ')

  if system("#{command} > #{BUILD_DIR}/latex.log 2>&1")
    puts "PDF Generated: #{pdf_dir}".green
    true
  else
    puts "Error generating PDF - check #{BUILD_DIR}/latex.log for details".red
    false
  end
end

def render_content(content_file)
  content_name = File.basename(content_file, '.yml')
  yaml_content = YAML.load_file(content_file)
  
  # Load YAML content into instance variables for ERB
  @title = yaml_content['title']
  @about = yaml_content['about']
  @info = yaml_content['info']
  @technical = yaml_content['technical']
  @education = yaml_content['education']
  @experiences = yaml_content['experiences']

  tex_dir, pdf_dir = ensure_output_directories(content_name)
  template = File.read('template.tex.erb')

  Dir.glob(File.join(CONFIG_DIR, "*.yml")) do |config_file|
    config_name = File.basename(config_file, '.yml')
    puts "Generating #{config_name}...".yellow

    begin
      Config.load_and_set_settings(
        File.join(CONFIG_DIR, 'default.yml'),
        config_file
      )
      puts Settings.to_s.faint

      renderer = ERB.new(template, trim_mode: '-')
      latex = renderer.result()

      tex_file = File.join(tex_dir, "#{config_name}.tex")
      File.write(tex_file, latex)
      puts "Tex Generated: #{tex_file}".green

      generate_pdf(tex_file, pdf_dir)
    rescue StandardError => e
      puts "Error processing #{config_name}: #{e.message}".red
    end
  end
end

# Process all YAML files in contents directory
Dir.glob(File.join(CONTENTS_DIR, "*.yml")) do |file|
  render_content(file)
end


