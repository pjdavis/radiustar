
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name        'radiustar'
  authors     'PJ Davis'
  email       'pj.davis@gmail.com'
  url         'http://github.com/pjdavis/radiustar'
  ignore_file '.gitignore'
  readme_file 'README.rdoc'
  depend_on 'ipaddr_extensions'
}

