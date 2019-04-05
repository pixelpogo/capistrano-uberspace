namespace :uberspace do
  def server_port
    @server_port ||= capture(:cat, "#{shared_path}/.server-port")
  end

  def start_server_command
    Capistrano::Uberspace.server_module.start_server_command(port: server_port, environment: fetch(:environment))
  end

end
