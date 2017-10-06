#
# Description: provide the dynamic list content from available tenants
#

#$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

list = {}

tenant_name = $evm.root["dialog_tenant_name"]
provider = nil

if tenant_name.blank?
  list['unspecified']="select tenant first"
else
  # try to find the provider object from the service template
  $evm.root['service_template'].service_resources.each { |resource|
    $evm.log("info", "Resource: #{resource.inspect}")
    if resource.resource_type == "ExtManagementSystem"
      $evm.log("info", "This resource is a provider: #{resource.inspect}")
      provider = resource.resource
      break
    end 
  }

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

  networks = subnets.body["subnets"]
  networks.each { |network|
    $evm.log("info", "Current network: #{network.inspect}")
    if network["tenant_id"]==tenant.ems_ref
      $evm.log("info", "Network is an external network, adding it to the list")
      networkname = network["name"]
      list[network["id"]]="#{networkname} on Provider #{provider.name}"
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
