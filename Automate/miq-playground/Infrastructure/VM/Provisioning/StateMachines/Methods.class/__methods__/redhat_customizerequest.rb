#
# Description: This method is used to Customize the RHEV, RHEV PXE, and RHEV ISO Provisioning Request
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
#

# Get provisioning object
prov = $evm.root["miq_provision"]

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "#{@method} Root:<$evm.root> Attribute - #{k}: #{v}")}

dialog_vmname = prov.get_option(:dialog_vmname)
if not dialog_vmname.nil?
  $evm.log("info", "Setting VM name to: #{dialog_vmname}")
  prov.set_option(:vm_target_name,dialog_vmname)
end

dialog_fqdn = prov.get_option(:dialog_fqdn)
if not dialog_fqdn.nil?
  $evm.log("info", "Setting FQDN to: #{dialog_fqdn}")
  prov.set_option(:vm_target_hostname,dialog_fqdn)
end

$evm.log("info", "Provisioning ID:<#{prov.id}> Provision Request ID:<#{prov.miq_provision_request.id}> Provision Type: <#{prov.provision_type}>")
