require 'rake/clean'

task :default => [:build, :clean]

task :build do |t|
  sh "ruby rollingstock.rb"
end

CLEAN << "_temp"

CLOBBER << "_temp"
CLOBBER << "cards"
CLOBBER << "sheets"
