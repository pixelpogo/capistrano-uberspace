namespace :uberspace do
  namespace :db do
    task :dump do
      available_tasks = %w{mysql postgresql sqlite3}.map do |db|
        "uberspace:#{db}:dump"
      end.select do |task|
        Rake::Task.task_defined?(task)
      end

      Rake.application[available_tasks.first].invoke
    end
  end

  task :check do
  end
  before :'deploy:check:linked_files', :'uberspace:check'

  task :setup_gemrc do
    gemrc = <<-EOF
gem: --user-install --no-rdoc --no-ri
    EOF

    on roles fetch(:uberspace_roles) do
      upload! StringIO.new(gemrc), "#{uberspace_home}/.gemrc"
    end
  end
  after :'uberspace:check', :'uberspace:setup_gemrc'

  task :setup_npmrc do
    npmrc = <<-EOF
prefix = #{uberspace_home}
umask = 077
    EOF

    on roles fetch(:uberspace_roles) do
      upload! StringIO.new(npmrc), "#{uberspace_home}/.npmrc"
    end
  end
  after :'uberspace:check', :'uberspace:setup_npmrc'

  task :install_bundler do
    on roles fetch(:uberspace_roles) do
      with fetch(:uberspace_env_variables, {}) do
        within(uberspace_home) do
          execute :gem,  'install bundler'
        end
      end
    end
  end
  after :'uberspace:setup_gemrc', :'uberspace:install_bundler'

  task :setup_secrets do
    on roles fetch(:uberspace_roles) do
      secrets = <<-EOF
#{fetch :environment}:
  secret_key_base: #{SecureRandom.hex 40}
      EOF

      execute :mkdir, "-p #{shared_path}/config"
      unless test "[ -f #{shared_path}/config/secrets.yml ]"
        upload! StringIO.new(secrets), "#{shared_path}/config/secrets.yml"
      end
    end
  end
  after :'uberspace:check', :'uberspace:setup_secrets'
end

namespace :deploy do
  task :start do
    on roles fetch(:uberspace_roles) do
      execute "supervisorctl start #{fetch :application}-daemon"
    end
  end

  task :stop do
    on roles fetch(:uberspace_roles) do
      execute "supervisorctl stop #{fetch :application}-daemon"
    end
  end

  task :restart do
    on roles fetch(:uberspace_roles) do
      execute "supervisorctl restart #{fetch :application}-daemon"
    end
  end
  after :publishing, :'deploy:restart'

  desc "Displays status information of the application."
  task :status do
    on roles fetch(:uberspace_roles) do
      execute "supervisorctl status #{fetch :application}-daemon"
    end
  end
end
