require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "merb_ajax"
NAME = "merb_ajax"
VERSION = "0.0.1"
AUTHOR = "Ulf Moehring"
EMAIL = "ulf@projecttray.com"
HOMEPAGE = "http://projecttray.com/svn/merb/merb_ajax"
SUMMARY = "Merb plugin that provides Rails-like helper methods for Ajax (prototype, scriptaculous)"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb-core', '>= 0.5')
  s.add_dependency('merb_helpers', '>= 0.5')
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,specs}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{VERSION}}
end
