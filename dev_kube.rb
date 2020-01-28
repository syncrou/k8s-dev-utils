#!/usr/bin/env ruby
# frozen_string_literal: true

require 'kubeclient'
require 'filewatcher'

src = ENV['SRC']
dest = ENV['DEST']
namespace = ENV['NAMESPACE']
svc = ENV['POD']

config = Kubeclient::Config.read(
  ENV['KUBECONFIG'] || "#{ENV['HOME']}/.kube/config"
)

@kube = Kubeclient::Client.new(
  config.context.api_endpoint,
  'v1',
  ssl_options: config.context.ssl_options,
  auth_options: config.context.auth_options
)

pod = @kube.get_pods(
  namespace: namespace, label_selector: "app=#{svc}"
).first.metadata.name

puts('syncing...')
system("oc --namespace #{namespace} rsync #{src} #{pod}:#{dest}")

Dir.chdir(src)

Filewatcher.new(['./**/*.*', './'],
                exclude: '.git/',
                spinner: true,
                interval: 0.1).watch do |filename, event|
  path = Pathname.new(filename)
  local_path = path.relative_path_from(Pathname.getwd)

  case event
  when :created, :updated
    puts "Transferring #{local_path}... "
    # " -> kubectl -n #{namespace} cp #{local_path} #{pod}:#{dest}#{local_path}"
    `kubectl -n #{namespace} cp #{local_path} #{pod}:#{dest}#{local_path}`
  end
end
