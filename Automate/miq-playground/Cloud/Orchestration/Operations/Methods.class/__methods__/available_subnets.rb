#
# Description: provide the dynamic list content from available subnets
#

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

external_network_id = $evm.root['dialog_param_external_network_id:']

external_network = $evm.vmdb("cloud_networks").where(:ems_ref => external_network_id)

$evm.log("info", "Found external_network #{external_network.inspect} by ems_ref #{external_network_id}")

#
#
#
#

# tenant_id = $evm.root['dialog_tenant_id']
# if tenant_id.blank?
#   list['unspecified']="select tenant first"
# else
#   tenant = $evm.vmdb("cloud_tenant").find_by_id(tenant_id)
#   $evm.log("info", "Found tenant #{tenant.name} by ID #{tenant_id}")

#   provider = tenant.ext_management_system
#   $evm.log("info", "Found provider #{provider.name} from tenant relationship")

#   $evm.log("info", "current provider: #{provider.inspect}")
#   if provider.type == "ManageIQ::Providers::Openstack::CloudManager"
#     $evm.log("info", "Provider #{provider.name} seems to be an OpenStack Provider")

#     $evm.log("info", "getting list of private networks aka subnets...")
#     $evm.log("info", "Output of tenant: #{tenant.inspect}")
#     subnets = provider.cloud_subnets
#     subnets.each { |subnet|
#       $evm.log("info", "Found Subnet: #{subnet.name} with ID #{subnet.ems_ref} and details: #{subnet.inspect}")
#       list[subnet.ems_ref]="#{subnet.name} on #{provider.name}"
#     }
#   end
# end 

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
