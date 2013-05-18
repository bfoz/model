# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
    gem.name          = "model"
    gem.version       = '0'
    gem.authors       = ["Brandon Fosdick"]
    gem.email         = ["bfoz@bfoz.net"]
    gem.description   = %q{3D Solid Modeling}
    gem.summary       = %q{Primitives and constructs for the design of everyday things}
    gem.homepage      = "http://github.com/bfoz/model"

    gem.files         = `git ls-files`.split($\)
    gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
    gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
    gem.require_paths = ["lib"]

    gem.add_dependency	'geometry', '~> 6'
    gem.add_dependency	'sketch', '~> 0.1'
end
