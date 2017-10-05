#
# Description: provide the dynamic list content from available subnets
#

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

tenant_id = $evm.root['dialog_tenant_id']

external_networks = $evm.vmdb("cloud_network").all

tenant_id = $evm.root['dialog_tenant_id']
if tenant_id.blank?
  list['unspecified']="select tenant first"
else
  tenant = $evm.vmdb("cloud_tenant").find_by_id(tenant_id)
  $evm.log("info", "Found tenant #{tenant.inspect} with ems_ref #{tenant.ems_ref} by ID #{tenant_id}")
end 

cloud_network = nil

if cloud_network.nil?
  $evm.log("info", "Failed to find selected network")
  list['unspecified']="select external network first"
else 
  $evm.log("info", "Found external_network #{cloud_network.inspect} by ems_ref #{external_network_id}")

  cloud_network.cloud_subnets.each { |subnet|
    $evm.log("info", "Adding subnet: #{subnet.name} with ems_ref #{subnet.ems_ref}")
    list[subnet.ems_ref]="#{subnet.name}"
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
