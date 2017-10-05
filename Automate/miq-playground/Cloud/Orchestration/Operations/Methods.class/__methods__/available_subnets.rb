#
# Description: provide the dynamic list content from available tenants
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
  $evm.log("info", "Found tenant #{tenant.name} with ems_ref #{tenant.ems_ref} by ID #{tenant_id}")

  provider = tenant.ext_management_system
  $evm.log("info", "Found provider #{provider.name} from tenant relationship")

  external_networks = provider.cloud_networks

  require 'rest-client'
  require 'json'
  require 'fog/openstack'

  credentials={
    :provider => "OpenStack",
    :openstack_api_key => provider.authentication_password,
    :openstack_username => provider.authentication_userid,
    :openstack_auth_url => "http://#{provider.hostname}:#{provider.port}/v3/auth/tokens",
    :openstack_project_name => tenant.name,
    :openstack_domain_name => provider.name
  }

  $evm.log("info", "Credentials: #{credentials.inspect}")

  network = Fog::Network.new(credentials)
  subnets = network.list_subnets
  $evm.log("info", "External Networks from FOG: #{subnets.body}")

  networks = subnets.body["networks"]
  networks.each { |network|
    $evm.log("info", "Current network: #{network.inspect}")
    $evm.log("info", "Network is an external network, adding it to the list")
    networkname = network["name"]
    list[network["id"]]="#{networkname} on Provider #{provider.name}"
  }

# external_networks = $evm.vmdb("cloud_network").all

# tenant_id = $evm.root['dialog_tenant_id']
# if tenant_id.blank?
#   list['unspecified']="select tenant first"
# else
#   subnets = $evm.vmdb("cloud_subnet").all 
#   subnets.each { |subnet|
#     $evm.log("info", "Subnet: #{subnet.inspect}")
#   }

#   tenants = $evm.vmdb("cloud_tenant").all 
#   tenants.each { |tenant|
#     $evm.log("info", "Tenant: #{tenant.inspect}")
#   }

#   cloud_networks = $evm.vmdb("cloud_network").all 
#   cloud_networks.each { |cloud_network|
#     $evm.log("info", "Cloud network: #{cloud_network.inspect}")
#     $evm.log("info", "CLoud network associated tenant: #{cloud_network.cloud_tenant.inspect}")
#     $evm.log("info", "CLoud network associated subnets: #{cloud_network.cloud_subnets.inspect}")
#   }

# end 

# cloud_network = nil

# if cloud_network.nil?
#   $evm.log("info", "Failed to find selected network")
#   list['unspecified']="select external network first"
# else 
#   $evm.log("info", "Found external_network #{cloud_network.inspect} by ems_ref #{external_network_id}")

#   cloud_network.cloud_tenants.each { |subnet|
#     $evm.log("info", "Adding subnet: #{subnet.name} with ems_ref #{subnet.ems_ref}")
#     list[subnet.ems_ref]="#{subnet.name}"
#   }
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
