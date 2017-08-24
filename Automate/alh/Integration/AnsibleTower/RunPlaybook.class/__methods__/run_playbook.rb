#
# Automate Method
#
# Copyright (C) 2016, Christian Jung
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

begin
  $evm.log("info", "EVM Automate Method Started")

  # Dump all of root's attributes to the log
  $evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}
  
  ANSIBLE_NAMESPACE = 'AutomationManagement/AnsibleTower/Operations/StateMachines'.freeze
  ANSIBLE_STATE_MACHINE_CLASS = 'Job'.freeze
  ANSIBLE_STATE_MACHINE_INSTANCE = 'default'.freeze
  VM_CLASS = 'VmOrTemplate'.freeze
  attrs = {}
  attrs['job_template_name'] = $evm.object['job_template_name']
  attrs['param1'] = $evm.object['param1'] unless $evm.object['param1']

  #
  # Passing an attribute of Vm::vm=id ensures that the executed method will
  # have $evm.root['vm'] pre-loaded with the VM with this ID
  #
  
  vm = nil
  
  if $evm.root['miq_provision'].nil?
    # probably called during retirement, we need to retreive from $evm.root
    $evm.log("info", "Looks like we're retiring, ...")
    vm = $evm.root['vm']
  else
    $evm.log("info", "Looks like we're provisioning, ...")
    prov = $evm.root["miq_provision"]
    vm = prov.vm
  end
  
  if vm.nil?
    $evm.log("info", "No VM object found! We still try to carry on...")
    exit MIQ_OK
  end
  
  $evm.log("info", "Running the playbook on VM: #{vm.name}")
  attrs['Vm::vm'] = vm.id
  
  # check on which provider we're running - if it's not in Testnetz (aka RHVMT) we remove '-testnetz'
  providerid = prov.get_option(:src_ems_id)
  provider = $evm.vmdb("ext_management_system").find_by_id(providerid)
  $evm.log("info", "Using provider: #{provider.inspect}")
  if not provider.name.include?("RHVMT")
    # remove substring '-testnetz' from the playbook name
    attrs['job_template_name'] = $evm.object['job_template_name'].gsub('-testnetz','')
    $evm.log("info", "Looks like this is NOT our Testnetz Provider, removing -testnetz from the playbook name")
  end

  #
  # make sure the VM is started
  #
  vm.start if vm.power_state != 'on'
  #
  # Call the job template as a new automation request in case it runs for
  # longer than 10 minutes
  #
  options = {}
  options[:namespace]     = ANSIBLE_NAMESPACE
  options[:class_name]    = ANSIBLE_STATE_MACHINE_CLASS
  options[:instance_name] = ANSIBLE_STATE_MACHINE_INSTANCE
  options[:user_id]       = $evm.root['user'].id
  options[:attrs]         = attrs
  auto_approve            = true
  request_object = $evm.execute('create_automation_request', options, $evm.root['user'].userid, auto_approve)
  $evm.log("info", "MIQ Request: #{request_object.inspect}")
  $evm.set_state_var(:request_id, request_object.id)
  
#  id = request_object['id']
#  $evm.log("info", "Request ID: #{id}")
  
#  $evm.vmdb(:automation_task).all.each { |miq_request|
#    $evm.log("info", "MIQ Request: #{miq_request.inspect}")
#  }
  
  #$evm.instantiate('/Discovery/ObjectWalker/object_walker')

  #
  # Exit method
  #
  $evm.log("info", "EVM Automate Method Ended")
  exit MIQ_OK

  #
  # Set Ruby rescue behavior
  #
rescue => err
  $evm.log("error", "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end
