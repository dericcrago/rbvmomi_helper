require 'rbvmomi'
require 'rbvmomi_helper/version'
require 'rbvmomi_helper/virtual_machine'

RbVmomi::VIM::VirtualMachine.send(:include, RbVmomiHelper::VirtualMachine)
