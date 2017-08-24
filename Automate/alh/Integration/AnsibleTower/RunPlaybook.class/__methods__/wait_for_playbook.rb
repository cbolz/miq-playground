#
#            Automate Method
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
  
  $evm.log("info", "Playbook running on VM: #{vm.name}")
  
  playbook_status = $evm.vmdb(:miq_request, $evm.get_state_var(:request_id))
  
  $evm.log("info", "Playbook Task Object: #{playbook_status.inspect}")
  
  case playbook_status.state
  when "pending", "active"
      $evm.log("info", "Playbook Task is still running, waiting for 30 secodns...")
      $evm.root['ae_retry_interval'] = '30.seconds'
      $evm.root['ae_result'] = 'retry'
  when "finished"
      $evm.log("info", "Playbook Task complated")
      $evm.root['ae_result'] = 'ok'
  else
      $evm.log("info", "Unexpected state")
      $evm.root['ae_result'] = 'error'
  end
  
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

