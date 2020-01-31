#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'yaml'
require 'bundler/setup'

Bundler.require

opts = Optimist.options do
  opt :repo, 'the git repository to build from', type: :string, default: 'https://github.com/RedHatInsights/catalog-api'
  opt :branch, 'push after building', default: 'master'
  opt :namespace, 'not catalog-ci', type: :string, default: "my-namespace-#{rand(100)}"
end


if opts[:namespace] == 'catalog-ci'
  puts "Cannot do work on the existing catalog-ci namespace"
  exit
end

puts("Building env for namespace #{opts[:namespace]}...")
system("oc new-project #{opts[:namespace]}")
#
# Write the namespace to a file
file = File.join(File.dirname(__FILE__), ".namespace.txt")
File.open(file, 'w') { |f| f.puts "#{opts[:namespace]}"}

puts "Importing secret from catalog-ci db"
system("./copy_catalog_db_secret.sh")

puts("Creating the local ephemeral postgres db")
system("oc create -f ./database.yml")

puts "Creating the builds for catalog and minion"
system("./create_build.rb --repo #{opts[:repo]} --branch #{opts[:branch]}")
sleep(20)

puts "Editing the deployment files with branch: #{opts[:branch]}"
catalog = YAML.load_file "configs/catalog.yml"
catalog['spec']['template']['spec']['containers'].first['image'] = "docker-registry.default.svc:5000/#{opts[:namespace]}/catalog-api"
File.open("configs/catalog-custom.yml", 'w') { |f| YAML.dump(catalog, f) }

puts "creating the deployment and service for catalog and the minions"
system("oc create -f configs/catalog-custom.yml")
system("oc create -f ./minions.yml")
