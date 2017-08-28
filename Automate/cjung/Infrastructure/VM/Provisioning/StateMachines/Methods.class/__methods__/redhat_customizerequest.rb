#
# Description: This method is used to Customize the RHEV, RHEV PXE, and RHEV ISO Provisioning Request
#

# Get provisioning object
prov = $evm.root["miq_provision"]

$evm.log("info", "Provisioning ID:<#{prov.id}> Provision Request ID:<#{prov.miq_provision_request.id}> Provision Type: <#{prov.provision_type}>")

$evm.root.attributes.sort.each { |k,v| $evm.log("info", "EVM:Root attributes: #{v}: #{k}") }

$evm.instantiate('/Discovery/ObjectWalker/object_walker')

providerid = prov.get_option(:src_ems_id)

$evm.log("info", "Provider ID: #{providerid}")

provider = $evm.vmdb("ext_management_system").find_by_id(providerid)

$evm.log("info", "Provider: #{provider.inspect}")

tshirtsize = prov.get_option(:dialog_tshirtsize)
vm_memory = prov.get_option(:dialog_vm_memory)
vm_cores = prov.get_option(:dialog_vm_cores)

case tshirtsize
when "M"
    prov.set_option(:vm_memory,4096)
    prov.set_option(:cores_per_socket,2)
    $evm.log("info", "T-Shirt Size Medium: 2 Cores, 4 GB RAM")
when "L"
    prov.set_option(:vm_memory,4096)
    prov.set_option(:cores_per_socket,4)
    $evm.log("info", "T-Shirt Size Large: 4 Cores, 4 GB RAM")
when "XL"
    prov.set_option(:vm_memory,8192) 
    prov.set_option(:cores_per_socket,4)
    $evm.log("info", "T-Shirt Size Extra Large: 4 Cores, 8 GB RAM")
else 
    $evm.log("warn", "Unkonwn T-Shirt Size!")
end

if vm_memory.to_i > 0
    prov.set_option(:vm_memory,vm_memory.to_i * 1024)
    $evm.log("info", "Memory Override: #{vm_memory}")
end
if vm_cores.to_i > 0
    prov.set_option(:cores_per_socket,vm_cores.to_i)
    $evm.log("info", "Cores Override: #{vm_cores}")
end

prov.set_option(:number_of_sockets, 1)

dialog_vlan = prov.get_option(:dialog_vm_vlan)

$evm.log("info", "VLAN list from Dialog: #{dialog_vlan}")

vlan_list={}

t = dialog_vlan.split('|')
t.each { |u|
    k,v=u.split('=')
    vlan_list[k]=v
}

$evm.log("info", "vlan_list: #{vlan_list}")

prov.set_option(:vlan,[vlan_list["RHV"],vlan_list["RHV"]])

prov.attributes.sort.each { |k,v| $evm.log("info", "Prov attributes: #{v}: #{k}") }
