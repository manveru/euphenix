#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'strscan'

s = StringScanner.new(File.read(ARGV[0]))
result = {}

case File.extname(ARGV[0])
when '.tmpl'
  s.scan_until(/<!--\n/)
  front = s.scan_until(/-->\n/)
  front_match = s.matched
  tmpl_source = s.rest

  if front
    yaml = "---\n" + front[0..-(front_match.size + 1)]
    result['meta'] = YAML.safe_load(yaml, [Date]) if front
  end

  meta['body'] = tmpl_source
when '.md'
  require 'date'
  require 'redcarpet'

  front = teaser = nil

  # only consider the start of the file for front-matter
  if s.scan(/---\n/)
    front = s.scan_until(/---\n/)
    front_match = s.matched
    teaser = s.scan_until(/<!--\s*more\s*-->/)
    teaser_match = s.matched
    s.unscan if teaser
  end

  markdown_source = s.rest

  markdown = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new,
    tables: true,
    autolink: true,
    space_after_headers: true,
    fenced_code_blocks: true,
    with_toc_data: true
  )

  result = { 'teaser' => '', 'meta' => {} }

  if front
    yaml = "---\n" + front[0..-(front_match.size + 1)]
    meta = YAML.safe_load(yaml, [Date]) if front
    if meta['title']
      meta['slug'] ||= meta['title'].strip.gsub(
        %r([;/?:@=&"<>#%{}|\\^~\[\]]+), '-'
      )
    end
    result['meta'] = meta
  end

  if teaser
    md = teaser[0..-(teaser_match.size + 1)].strip
    result['teaser'] = markdown.render(md)
  end

  result['body'] = markdown.render(
    markdown_source.gsub(/<!--\s*more\s*-->/, '')
  )
end

puts JSON.pretty_unparse(result)
