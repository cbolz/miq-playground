#
# Description: provide the dynamic list content from external networks
#

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

tenant_id = $evm.root['dialog_tenant_id']
if tenant_id.blank?
  list['unspecified']="select tenant first"
else
  tenant = $evm.vmdb("cloud_tenant").find_by_id(tenant_id)
  $evm.log("info", "Found tenant #{tenant.name} by ID #{tenant_id}")

  provider = tenant.ext_management_system
  $evm.log("info", "Found provider #{provider.name} from tenant relationship")

  external_networks = provider.cloud_networks
  external_networks.each { |external_network|
    $evm.log("info", "External Network: #{external_network.inspect}")
    $evm.log("info", "Found external_network: #{external_network.name} with ID #{external_network.ems_ref} and cloud_tenant #{external_network.cloud_tenant.inspect}")
    if external_network.cloud_tenant_id == tenant_id
      $evm.log("info", "Adding network to dialog, tenant ID does match")
      list[external_network.ems_ref]="#{external_network.name} on #{provider.name}"
    else 
      $evm.log("info", "Ignoring network since tenant ID doesn't match")
    end 
  }
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
