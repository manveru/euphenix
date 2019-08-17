#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'date'
require 'pathname'
require 'set'
require 'strscan'
require 'yaml'

DIRECTORY = Pathname(File.expand_path(ARGV[0]))
TMPL_IMPORT = /\{\{\s*template\s*"([^\"]+)".*\}\}/.freeze

templates = {}

Dir.glob(File.expand_path('**/*.html', DIRECTORY)) do |path|
  content = File.read(path)

  template = { 'imports' => [path], 'meta' => {}, 'body' => content }

  content.scan(TMPL_IMPORT).flatten.uniq.each do |import|
    absolute = File.expand_path(import, File.dirname(path))
    template['imports'] << absolute
  end

  if /\A\s*(<!--\n(?<front>.+?)\s+-->)\s*(?<body>.*)/m =~ content
    if front
      yaml = "---\n" + front
      meta = YAML.safe_load(yaml, [Date])
      meta['slug'] ||= meta['title'].strip.gsub(/\W+/, '-') if meta['title']
      template['meta'] = meta
    end

    template['body'] = body if body
  end

  templates[path] = template
end

templates.each do |_, data|
  complete_imports = data['imports']

  data['imports'].flat_map do |i|
    templates.each do |inner_path, inner_data|
      complete_imports |= inner_data['imports'] if inner_path == i
    end
  end

  data['imports'] = complete_imports
end

templates.each do |_, data|
  data['imports'].map! do |import|
    Pathname(import).relative_path_from(DIRECTORY).to_s
  end
end

puts JSON.pretty_unparse(templates)
