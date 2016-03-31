require 'rbvmomi'

module RbVmomiHelper
  # VirtualMachine Class
  module VirtualMachine
    def initialize(connection, ref)
      super(connection, ref)
      @gom = @connection.serviceContent.guestOperationsManager
    end

    def configure_auth(username, password, interactiveSession = false)
      @auth = RbVmomi::VIM::NamePasswordAuthentication(
        username: username,
        password: password,
        interactiveSession: interactiveSession
      )
    end

    def create_temporary_file(prefix, suffix)
      raise "please 'configure_auth' first" unless @auth

      @gom.fileManager.CreateTemporaryFileInGuest(
        vm: self,
        auth: @auth,
        prefix: prefix,
        suffix: suffix
      )
    end

    def delete_file(file_path)
      raise "please 'configure_auth' first" unless @auth

      @gom.fileManager.DeleteFileInGuest(
        vm: self,
        auth: @auth,
        filePath: file_path
      )
    end

    def list_processes(pids = [])
      @gom.processManager.ListProcessesInGuest(
        vm: self,
        auth: @auth,
        pids: [*pids]
      )
    end

    def start_program(program_path, arguments = '',
                      working_directory = nil, env_variables = nil)
      raise "please 'configure_guest_auth' first" unless @auth

      program_spec = RbVmomi::VIM::GuestProgramSpec(
        programPath: program_path,
        arguments: arguments,
        workingDirectory: working_directory,
        envVariables: env_variables
      )

      @gom.processManager.StartProgramInGuest(
        vm: self,
        auth: @auth,
        spec: program_spec
      )
    end

    def put_file(source, destination = nil, overwrite = true)
      destination = get_destination_path(source, destination)
      url = initiate_file_transfer_to(source, destination, overwrite)
      uri = URI.parse(url)

      http = setup_http(uri)
      request = setup_put_request(uri, source)

      response = http.request(request)
      process_response(response) ? destination : response
    end

    def validate_credentials
      raise "please 'configure_guest_auth' first" unless @auth

      @gom.authManager.ValidateCredentialsInGuest(
        vm: self,
        auth: @auth
      )
    end

    private

    def get_destination_path(source, destination)
      destination ? get_file_path(destination) : get_file_path(source)
    end

    def get_file_path(file_path)
      # return file_path if file_path is absolute
      # aka, starts with '/' or 'SOME_LETTER:'
      return file_path if file_path =~ %r{\A(/|[a-zA-Z]:)}
      suffix = File.extname(file_path)
      prefix = File.basename(file_path, suffix) + '_'
      create_temporary_file(prefix, suffix)
    end

    def file_attributes
      case guest.guestFamily
      when 'linuxGuest'
        RbVmomi::VIM::GuestPosixFileAttributes()
      when 'windowsGuest'
        RbVmomi::VIM::GuestWindowsFileAttributes()
      else
        raise 'unrecognized guestFamily'
      end
    end

    def initiate_file_transfer_to(source, destination, overwrite)
      raise "please 'configure_guest_auth' first" unless @auth

      @gom.fileManager.InitiateFileTransferToGuest(
        vm: self,
        auth: @auth,
        guestFilePath: destination,
        fileAttributes: file_attributes,
        fileSize: File.size(source),
        overwrite: overwrite
      )
    end

    def setup_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      configure_https(http) if uri.scheme == 'https'

      http
    end

    def configure_https(http)
      opts = @connection.instance_variable_get('@opts')

      http.use_ssl = true
      http.verify_mode =
        if opts.fetch(:insecure, false)
          OpenSSL::SSL::VERIFY_NONE
        else
          OpenSSL::SSL::VERIFY_PEER
        end
    end

    def setup_put_request(uri, source)
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body_stream = File.open(source)
      request['Content-Type'] = 'multipart/form-data'
      request.add_field('Content-Length', File.size(source))

      request
    end

    def process_response(response)
      response.code == '200'
    end
  end
end
