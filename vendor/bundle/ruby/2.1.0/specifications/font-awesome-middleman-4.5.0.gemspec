# -*- encoding: utf-8 -*-
# stub: font-awesome-middleman 4.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "font-awesome-middleman"
  s.version = "4.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Cristian Ferrari, Miguel Michelson"]
  s.date = "2015-12-10"
  s.description = "font-awesome-middleman provides the Font-Awesome web fonts and stylesheets as a Middleman engine."
  s.email = ["cristianferrarig@gmail.com, miguelmichelson@gmail.com"]
  s.homepage = ""
  s.rubygems_version = "2.2.2"
  s.summary = "Font-Awesome web fonts and stylesheets as a Middleman engine"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<middleman-core>, ["~> 3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
    else
      s.add_dependency(%q<middleman-core>, ["~> 3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.1"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    end
  else
    s.add_dependency(%q<middleman-core>, ["~> 3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.1"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
  end
end
