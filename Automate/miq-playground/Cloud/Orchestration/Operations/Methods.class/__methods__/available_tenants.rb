#
# Description: provide the dynamic list content from available tenants
#

$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

providers = $evm.vmdb("ext_management_system").all
providers.each { |provider| 
  if provider.type == "ManageIQ::Providers::Openstack::NetworkManager"
    $evm.log("info", "Provider #{provider.name} seems to be an OpenStack Network Provider, getting list tenants...")
    $evm.log("info", "Hosts: #{provider.hosts}")
    if provider.hosts.length > 0 
      $evm.log("info", "Providers returns more than one host, this must be an UnderCloud, skipping")
      next
    end 

    $evm.log("info", "current provider: #{provider.inspect}")
    tenants = provider.cloud_tenants
    tenants.each { |tenant|
      $evm.log("info", "External Network: #{tenant.inspect}")
      $evm.log("info", "Found external_network: #{tenant.name}")
      list[tenant.ems_ref]="#{tenant.name} on #{provider.name}"
    }
  end
}

# external_networks = $evm.vmdb("cloud_networks").all
# external_networks.each { |external_network|
#   $evm.log("info", "Finding cloud networks: #{external_network.inspect}")
# }


dialog_field = $evm.object 

# sort_by: value / description / none
dialog_field["sort_by"] = "description"

# sort_order: ascending / descending
dialog_field["sort_order"] = "ascending"

# data_type: string / integer
dialog_field["data_type"] = "string"

# required: true / false
dialog_field["required"] = "false"

dialog_field["values"] = list
dialog_field["default_value"] = nil
