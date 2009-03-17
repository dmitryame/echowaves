--- !ruby/object:Gem::Specification 
rubygems_version: 0.8.11
specification_version: 1
name: mysql
version: !ruby/object:Gem::Version 
  version: "2.7"
date: 2005-10-10 00:00:00 +02:00
summary: MySQL/Ruby provides the same functions for Ruby programs that the MySQL C API provides for C programs.
require_paths: 
  - lib
email: tommy@tmtm.org
homepage: http://www.tmtm.org/en/mysql/ruby/
autorequire: mysql
has_rdoc: false
required_ruby_version: !ruby/object:Gem::Version::Requirement 
  requirements: 
    - 
      - ">"
      - !ruby/object:Gem::Version 
        version: 0.0.0
  version: 
platform: ruby
files: 
  - COPYING
  - COPYING.ja
  - README.html
  - README_ja.html
  - extconf.rb
  - mysql.c.in
  - test.rb
  - tommy.css
  - mysql.gemspec
extensions: 
  - extconf.rb
