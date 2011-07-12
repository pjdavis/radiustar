# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{radiustar}
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["PJ Davis", "Davide Guerri", "James Harton"]
  s.date = %q{2011-07-11}
  s.description = %q{Ruby Radius Library}
  s.email = %q{jamesotron@gmail.com}
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "templates/default.txt", "version.txt"]
  s.files = [".gitignore", "History.txt", "README.rdoc", "Rakefile", "lib/radiustar.rb", "lib/radiustar/dictionary.rb", "lib/radiustar/dictionary/attributes.rb", "lib/radiustar/dictionary/values.rb", "lib/radiustar/packet.rb", "lib/radiustar/radiustar.rb", "lib/radiustar/request.rb", "lib/radiustar/vendor.rb", "radiustar.gemspec", "spec/radiustar_spec.rb", "spec/spec_helper.rb", "templates/default.txt", "templates/dictionary.digium", "templates/gandalf.dictionary", "test/test_radiustar.rb", "version.txt"]
  s.homepage = %q{http://github.com/dguerri/radiustar}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{radiustar}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby Radius Library}
  s.test_files = ["test/test_radiustar.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones>, [">= 3.4.1"])
      s.add_development_dependency(%q<ipaddr_extensions>)
    else
      s.add_dependency(%q<bones>, [">= 3.4.1"])
      s.add_dependency(%q<ipaddr_extensions>)
    end
  else
    s.add_dependency(%q<bones>, [">= 3.4.1"])
    s.add_dependency(%q<ipaddr_extensions>)
  end
end
