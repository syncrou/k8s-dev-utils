#!/home/dbomhof/.rubies/ruby-2.5.7/bin/ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'kubeclient'
require 'filewatcher'

src = ENV['SRC'] || "/home/dbomhof/onramp"
dest = ENV['DEST'] || "/var/www/onramp/"
namespace = ENV['NAMESPACE'] || "cdg"
svc = ENV['POD'] || "onramp"
skip_tls = { :verify_ssl => false }

config = Kubeclient::Config.read(
  ENV['KUBECONFIG'] || "#{ENV['HOME']}/.kube/config"
)

@kube = Kubeclient::Client.new(
  config.context.api_endpoint,
  'v1',
  ssl_options: config.context.ssl_options.merge!(skip_tls),
  auth_options: config.context.auth_options
)
if namespace == "cdg"
  pod = @kube.get_pods(
    namespace: namespace, label_selector: "app=#{svc}"
  ).first.metadata.name
else
  puts "NAMESPACE = #{namespace}"
  pod = @kube.get_pods(
    namespace: namespace, label_selector: "run=#{svc}"
  ).first.metadata.name
end

puts('syncing...')
#system("oc --namespace #{namespace} rsync #{src} #{pod}:#{dest}")
system("oc --insecure-skip-tls-verify=true --namespace #{namespace} rsync #{src} #{pod}:#{dest}")

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
    #`kubectl -n #{namespace} cp #{local_path} #{pod}:#{dest}#{local_path}`
    `kubectl --insecure-skip-tls-verify -n #{namespace} cp #{local_path} #{pod}:#{dest}#{local_path}`
  end
end
