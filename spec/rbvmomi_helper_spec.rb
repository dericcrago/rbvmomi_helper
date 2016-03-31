require 'spec_helper'

describe RbVmomiHelper do
  before(:all) do
    VCR.use_cassette('connection') do
      options = {
        host: 'vcenter.yourdomain.here',
        user: 'root',
        password: 'vmware',
        insecure: true
      }
      @vim = RbVmomi::VIM.connect(options)
      @linux_vm = @vim.searchIndex.FindByUuid(
        uuid: '422807fd-547f-a2e5-4a0e-0b337708502c',
        vmSearch: true
      )
      @linux_vm.configure_auth('root', 'vmware')
      @windows_vm = @vim.searchIndex.FindByUuid(
        uuid: '42289b55-e186-fec6-fe08-972988974f86',
        vmSearch: true
      )
      @windows_vm.configure_auth('Administrator', 'vmware')
    end
  end

  it 'has a version number' do
    expect(RbVmomiHelper::VERSION).not_to(be(nil))
  end

  # Expect Password Validation
  it 'validates the linux_vm username and password', :vcr do
    expect { @linux_vm.validate_credentials }.to_not(raise_error)
  end

  it 'validates the windows_vm username and password', :vcr do
    expect { @windows_vm.validate_credentials }.to_not(raise_error)
  end

  # Expect Guest Temp File Creation
  it 'creates a temp file in the linux_vm', :vcr do
    temp_file = @linux_vm.create_temporary_file('prefix', '.suffix')

    expect(temp_file).to_not(eq(nil))
    expect(temp_file).to(include('prefix'))
    expect(temp_file).to(include('.suffix'))
  end

  it 'creates a temp file in the windows_vm', :vcr do
    temp_file = @windows_vm.create_temporary_file('prefix', '.suffix')

    expect(temp_file).to_not(eq(nil))
    expect(temp_file).to(include('prefix'))
    expect(temp_file).to(include('.suffix'))
  end

  # Expect Guest File Transfer
  it 'transfers a file to the linux_vm', :vcr do
    file_path = @linux_vm.put_file('spec/etc/sleep.sh')

    expect(file_path).to_not(eq(nil))
    expect(file_path).to(include('sleep'))
    expect(file_path).to(include('.sh'))
  end

  it 'transfers a file to the linux_vm with a provided name', :vcr do
    file_path = @linux_vm.put_file('spec/etc/sleep.sh', 'sleep_test.sh')

    expect(file_path).to_not(eq(nil))
    expect(file_path).to(include('sleep_test'))
    expect(file_path).to(include('.sh'))
  end

  it 'transfers a file to the linux_vm with an exact path', :vcr do
    file_path = @linux_vm.put_file('spec/etc/sleep.sh', '/tmp/sleep.sh')

    expect(file_path).to(eq('/tmp/sleep.sh'))
  end

  it 'transfers a file to the windows_vm', :vcr do
    file_path = @windows_vm.put_file('spec/etc/sleep.bat')

    expect(file_path).to_not(eq(nil))
    expect(file_path).to(include('sleep'))
    expect(file_path).to(include('.bat'))
  end

  it 'transfers a file to the windows_vm with a provided name', :vcr do
    file_path = @windows_vm.put_file('spec/etc/sleep.bat', 'sleep_test.bat')

    expect(file_path).to_not(eq(nil))
    expect(file_path).to(include('sleep_test'))
    expect(file_path).to(include('.bat'))
  end

  it 'transfers a file to the windows_vm with an exact path', :vcr do
    file_path = @windows_vm.put_file('spec/etc/sleep.bat', 'C:\sleep.bat')

    expect(file_path).to(eq('C:\sleep.bat'))
  end

  # Expect Start Program
  it 'starts a program in the linux_vm', :vcr do
    pid = @linux_vm.start_program('/bin/bash', '/tmp/sleep.sh')
    expect(pid).not_to(be(nil))
  end

  it 'starts a program in the windows_vm', :vcr do
    pid = @windows_vm.start_program('C:\sleep.bat')
    expect(pid).not_to(be(nil))
  end

  # Expect Processes
  it 'retrieves the processes in the linux_vm', :vcr do
    pid = @linux_vm.start_program('/bin/bash', '/tmp/sleep.sh')
    processes = @linux_vm.list_processes(pid)

    expect(processes.first.pid).to(eq(pid))
  end

  it 'retrieves the processes in the windows_vm', :vcr do
    pid = @windows_vm.start_program('C:\sleep.bat')
    processes = @windows_vm.list_processes(pid)

    expect(processes.first.pid).to(eq(pid))
  end

  # Expect File Deletion
  it 'deletes a file in the linux_vm', :vcr do
    expect { @linux_vm.delete_file('/tmp/sleep.sh') }.to_not(raise_error)
  end

  it 'deletes a file in the windows_vm', :vcr do
    expect { @windows_vm.delete_file('C:\sleep.bat') }.to_not(raise_error)
  end
end
