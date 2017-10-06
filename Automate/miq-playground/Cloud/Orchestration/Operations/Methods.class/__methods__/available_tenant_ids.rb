#
# Description: provide the dynamic list content from available tenants
#

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

$evm.log("info", "Retrieving list of cloud tenants...")
tenants = $evm.vmdb("cloud_tenant").all
tenants.each { |tenant|
  $evm.log("info", "Current tenant: #{tenant.inspect}")
  provider = tenant.ext_management_system
  if provider.nil?
    $evm.log("info", "Tenant does not have an ext_management_system relationship")
    next 
  end 
  $evm.log("info", "Tenant on provider #{provider.name}")
  list[tenant.id]="#{tenant.name} on #{provider.name}"
}

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
