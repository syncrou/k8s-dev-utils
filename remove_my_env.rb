#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

Bundler.require

puts "Checking the current namespace is saved"
if File.exist?('.namespace.txt')
  namespace = File.open(".namespace.txt").read
  if namespace == 'catalog-ci'
    puts "Cannot remove namespace 'catalog-ci'"
    exit
  else
    puts "Deleting namespace #{namespace}"
    system("oc delete project #{namespace}")
    File.delete(".namespace.txt")
  end
else
  puts "No saved namespace. Quitting"
  exit
end
puts "Namespace removed changing back to 'catalog-ci'"
system("oc project catalog-ci")

