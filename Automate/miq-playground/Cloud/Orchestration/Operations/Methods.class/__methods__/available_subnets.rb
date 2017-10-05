#
# Description: provide the dynamic list content from available subnets
#

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

tenant_id = $evm.root['dialog_tenant_id']
if tenant_id.blank?
  list['unspecified']="select tenant first"
else
  providers = $evm.vmdb("ext_management_system").all
  providers.each { |provider| 
    $evm.log("info", "current provider: #{provider.inspect}")
    if provider.type == "ManageIQ::Providers::Openstack::NetworkManager"
      $evm.log("info", "Provider #{provider.name} seems to be an OpenStack Network Provider, getting list of private networks aka subnets...")
      $evm.log("info", "Hosts: #{provider.hosts}")
      if provider.hosts.length > 0 
        $evm.log("info", "Providers returns more than one host, this must be an UnderCloud, skipping")
        next
      end 
      subnets = provider.cloud_subnets
      subnets.each { |subnet|
        $evm.log("info", "Found Subnet: #{subnet.name} with ID #{subnet.ems_ref}")
        list[subnet.ems_ref]="#{subnet.name} on #{provider.name}"
      }
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
