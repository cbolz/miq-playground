#
# Description: provide the dynamic list content from available subnets
#

$evm.instantiate('/Discovery/ObjectWalker/object_walker')

list = {}

tenant_name = $evm.root['dialog_tenant_name']
if tenant_name.nil?
  list['unspecified']="select tenant first"
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
