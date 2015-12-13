# -*- encoding: utf-8 -*-
# stub: rails-assets-font-awesome 4.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-assets-font-awesome"
  s.version = "4.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["rails-assets.org"]
  s.date = "2015-12-08"
  s.description = "Font Awesome"
  s.homepage = "http://fontawesome.io/"
  s.licenses = ["OFL-1.1", "MIT", "CC-BY-3.0"]
  s.rubygems_version = "2.2.2"
  s.summary = "Font Awesome"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
