#
# Description: provide the dynamic list content from external networks
#

$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

tenant_name = $evm.root['dialog_tenant_name']
if tenant_name.blank?
  list['unspecified']="select tenant first"
else
  providers = $evm.vmdb("ext_management_system").all
  providers.each { |provider| 
    $evm.log("info", "current provider: #{provider.inspect}")
    if provider.type == "ManageIQ::Providers::Openstack::NetworkManager"
      $evm.log("info", "Provider #{provider.name} seems to be an OpenStack Network Provider, getting list of private networks aka external_networks...")
      $evm.log("info", "Hosts: #{provider.hosts}")
      if provider.hosts.length > 0 
        $evm.log("info", "Providers returns more than one host, this must be an UnderCloud, skipping")
        next
      end 
      external_networks = provider.cloud_networks
      external_networks.each { |external_network|
        $evm.log("info", "Found external_network: #{external_network.name} with ID #{external_network.ems_ref}")
        list[external_network.ems_ref]="#{external_network.name} on #{provider.name}"
      }
    end
  }

  external_networks = $evm.vmdb(:cloud_networks).where(:cloud_tenant => tenant_name)
  $evm.log("info", "Finding cloud networks with tenant name #{tenant_name}: #{external_networks.inspect}")
end

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
