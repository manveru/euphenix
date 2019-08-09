#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'pathname'
require 'set'

ORIGIN = Pathname(File.expand_path(ARGV[0]))
CSS_IMPORT = /^@import ['"']([^\'\"]+)['"']/.freeze

def deps(path, seen = Set.new)
  return seen if seen.include?(path)

  seen << path

  File.read(path).scan(CSS_IMPORT).flatten.uniq.each do |name|
    dep = File.expand_path("#{name}.css", File.dirname(path))
    deps(dep, seen)
  end

  seen
end

def relative(path)
  Pathname(path).relative_path_from(ORIGIN).to_s
end

roots = {}

Dir.glob(File.expand_path('**/*.css', ARGV[0])) do |root|
  roots[relative(root)] = deps(root).map do |dep|
    relative(dep)
  end
end

puts JSON.pretty_unparse(roots)
