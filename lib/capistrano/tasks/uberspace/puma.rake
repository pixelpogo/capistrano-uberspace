namespace :uberspace do
  namespace :puma do
    task :setup_apache_reverse_proxy do
      on roles fetch(:uberspace_roles) do
        path = fetch(:domain) ? "/var/www/virtual/#{fetch :user}/#{fetch :domain}" : "/var/www/virtual/#{fetch :user}/html"
        execute "rm -fr #{path}"
        execute "ln -s #{release_path}/public #{path}"
        basic_auth = ''

        if fetch(:htaccess_username, false)
          unless fetch(:htaccess_password_hashed, false)
            password = fetch(:htaccess_password, -> { abort 'ERROR: Define either :htaccess_password or :htaccess_password_hashed'})
            salt = [*'0'..'9',*'A'..'Z',*'a'..'z'].sample(2).join
            set :htaccess_password_hashed, "#{password}".crypt(salt)
          end

          htpasswd = <<-HTPASSWD.gsub(/^ {12}/, '')
            #{fetch :htaccess_username}:#{fetch :htaccess_password_hashed}
          HTPASSWD
          upload! StringIO.new(htpasswd), "#{path}/../.htpasswd"

          basic_auth = <<-BASICAUTH.gsub(/^ {12}/, '')
            AuthType Basic
            AuthName "Restricted"
            AuthUserFile #{File.join(path, '../.htpasswd')}
            Require valid-user
          BASICAUTH
          execute "chmod +r #{path}/../.htpasswd"
        end

        htaccess = <<-HTACCESS.gsub(/^ {10}/, '')
          #{basic_auth}
          RewriteEngine On
          RewriteBase /
          RewriteCond %{SERVER_PORT} ^80$
          RewriteRule .* https://%{SERVER_NAME}%{REQUEST_URI} [R,L]
          RewriteCond %{REQUEST_FILENAME} !-f
          RewriteRule ^(.*)$ http://localhost:#{server_port}/$1 [P]
        HTACCESS

        execute "echo '\n\n-------    BAM-release_path: #{release_path}! ------\n\n\n\n'"
        upload! StringIO.new(htaccess), "#{release_path}/public/.htaccess"
        execute "chmod +r #{release_path}/public/.htaccess"

        if fetch(:domain)
          execute "uberspace-add-domain -qwd #{fetch :domain} ; true"
          if fetch(:add_www_domain)
            wwwpath = "/var/www/virtual/#{fetch :user}/www.#{fetch :domain}"
            execute "ln -nfs #{path} #{wwwpath}"
            execute "uberspace-add-domain -qwd www.#{fetch :domain} ; true"
          end
        end
      end
    end
  end
  after :'deploy:published', :'uberspace:puma:setup_apache_reverse_proxy'
end
