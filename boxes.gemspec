# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "boxes/version"

Gem::Specification.new do |s|
  s.name        = "boxes"
  s.version     = Boxes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thierry Passeron"]
  s.email       = ["tp@montecarlo-computing.com"]
  s.homepage    = "https://github.com/Orion98MC/Boxes"
  s.summary     = %q{Boxes adds CMS-like ability to your Rails Application}
  s.description = %q{Boxes is powered by Apotomo. With Boxes you concentrate on making great widgets and let the tedious work of organizing and configuring to boxes}
  s.license     = 'MIT'

  s.rubyforge_project = "boxes"
  
  s.add_dependency('apotomo', '>= 1.0.1')
  s.add_dependency('acts_as_list', '>= 0.1.2')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
