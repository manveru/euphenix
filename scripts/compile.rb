#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

out = ENV.fetch('out')
route = ENV.fetch('route')
template = ENV.fetch('template').dup

FileUtils.mkdir_p(ENV.fetch('out'))
FileUtils.mkdir_p(File.join(out, '/css'))

template.gsub!(%r{<<<(?<path>/nix/store/[^>]+)>>>}) do
  names = []

  Dir.glob(Regexp.last_match[:path] + '**/*') do |file|
    names << File.basename(file) if File.extname(file) == '.css'
    FileUtils.cp(file, out + '/css')
  end

  names.map do |name|
    %(<link rel="stylesheet" href="/css/#{name}" />)
  end.join("\n")
end

FileUtils.mkdir_p(File.dirname(File.join(out, route)))

File.write(File.join(out, route), template)
