# frozen_string_literal: true

hanami_env = ENV.fetch('HANAMI_ENV', 'development')
app_root = Dir.pwd

if !ENV.include?('PORT') && hanami_env == 'production'
  sockets_dir = File.expand_path('tmp/sockets', app_root)
  Dir.mkdir(sockets_dir) unless FileTest.directory?(sockets_dir)
  bind "unix://#{File.join(sockets_dir, 'puma.sock')}"
else
  port ENV.fetch('PORT', 2300)
end

environment hanami_env

if hanami_env == 'production'
  pids_dir = File.expand_path('tmp/pids', app_root)
  Dir.mkdir(pids_dir) unless FileTest.directory?(pids_dir)
  pidfile File.join(pids_dir, 'puma.pid')
  stdout_redirect(File.expand_path('log/puma.log', app_root),
                  File.expand_path('log/puma-error.log', app_root),
                  true)
end
