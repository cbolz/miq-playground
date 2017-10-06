#
# Description: use the tenant ID to find tenant name and store it in the options hash
#

$evm.instantiate('/Discovery/ObjectWalker/object_walker')

# Dump all of root's attributes to the log
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

prov = $evm.root['service_template_provision_task']

service_template_provision_task

$evm.log("info", "Provisioning object: #{prov.inspect}")

tenant_id = $evm.root["dialog_tenant_id"]

# find tenant by ID
if tenant_id.blank?
    $evm.log("info", "could not find tenant")
else
    tenant = $evm.vmdb("cloud_tenant").find_by_id(tenant_id)
    $evm.log("info", "Found tenant by ID #{tenant_id}: #{tenant.inspect}")
    $evm.log("info", "Store dialog_tenant_name and tenant_name with value #{tenant.name}")
    prov.set_option("dialog_tenant_name", "#{tenant.name}")
    prov.set_option("tenant_name", "#{tenant.name}")
end
