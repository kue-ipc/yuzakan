hanami_env = ENV.fetch('HANAMI_ENV') { 'development' }
app_root = Dir.pwd

if !ENV.include?('PORT') && hanami_env == 'production'
  bind "unix://#{File.expand_path('tmp/sockets/puma.sock', app_root)}"
else
  port ENV.fetch('PORT', 2300)
end

environment hanami_env

if hanami_env == 'production'
  pidfile File.expand_path('tmp/pids/puma.pid', app_root)
  stdout_redirect(File.expand_path('log/puma.log', app_root),
                  File.expand_path('log/puma-error.log', app_root),
                  true)
end
