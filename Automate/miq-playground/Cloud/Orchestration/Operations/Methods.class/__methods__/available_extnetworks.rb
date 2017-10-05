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
    :openstack_auth_url => "http://#{provider.hostname}:#{provider.port}/v2.0/tokens",
    :openstack_project_name => tenant.ems_ref
    :openstack_domain_name => provider.name
  }

  network = Fog::Network.new(credentials)
  external_networks = network.list_networks
  $evm.log("info", "External Networks from FOG: #{external_networks}")

  # external_networks.each { |external_network|
  #   $evm.log("info", "Found external_network: #{external_network.name} with ID #{external_network.ems_ref}")
  #   if external_network.cloud_tenant.nil?
  #     $evm.log("info", "This network does not have a tenant, ignoring it")
  #   else 
  #     $evm.log("info", "Checking cloud_tenant from external_network: #{external_network.cloud_tenant.id.inspect} and tenant ID from dialog: #{tenant_id.inspect}")      
  #     if external_network.cloud_tenant.id.to_i == tenant_id.to_i
  #       $evm.log("info", "Adding network to dialog, tenant ID does match")
  #       list[external_network.ems_ref]="#{external_network.name} on #{provider.name}"
  #     else 
  #       $evm.log("info", "Ignoring network since tenant ID doesn't match")
  #     end 
  #   end 
  # }
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
