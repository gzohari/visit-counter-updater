# -*- encoding: utf-8 -*-
require File.expand_path('../lib/visit_counter_updater/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gilad Zohari"]
  gem.email         = ["gilad@ftbpro.com"]
  gem.description   = %q{Extending VisitCounter to stage all data to DB}
  gem.summary       = %q{Tom Caspy is a lazi individual.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "visit_counter_updater"
  gem.require_paths = ["lib"]
  gem.version       = VisitCounterUpdater::VERSION
  gem.add_dependency(%q<visit-counter>, [">= 0"])
end
