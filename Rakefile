
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name        'dguerri-radiustar'
  authors     'PJ Davis', 'Davide Guerri'
  email       'davide.guerri@gmail.com'
  url         'http://github.com/dguerri/radiustar'
  ignore_file '.gitignore'
  readme_file 'README.rdoc'

}

