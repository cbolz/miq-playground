#
# get list of networks
#
# Copyright (C) 2016, Christian Jung
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

begin
    $evm.log("info", "EVM Automate Method Started")
  
    # Dump all of root's attributes to the log
    $evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}
  
    #$evm.root.methods.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}
   
    #$evm.instantiate('/Discovery/ObjectWalker/object_walker')

    #service_template = $evm.root["service_template"]
    
    #resource = $evm.root['service_template'].service_resources.first
    #resource.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

    #vlans = resource.(:vlan)
    #$evm.log("info", "VLANS: #{vlans}")
  
    #service_template.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}
    
    #service_template.methods.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}

    #source = $evm.root['service_template'].service_resources.first.resource.source
    #source.attributes.sort.each { |k, v| $evm.log("info", "Source:<$evm.root> Attribute - #{k}: #{v}")}
    
    providerid = $evm.root['service_template'].service_resources.first.resource.source.ems_id

    $evm.log("info", "provider: #{providerid}")

    provider = $evm.vmdb(:ext_management_system).find_by_id(providerid)

    provider.attributes.sort.each { |k, v| $evm.log("info", "Provider:<$evm.root> Attribute - #{k}: #{v}")}

    #provider.virtual_column_names.sort.each { |k, v| $evm.log("info", "virtual column:<$evm.root> Attribute - #{k}: #{v}")}

    lans = $evm.vmdb('lan').all
    
    list_of_lans={}

    lans.each { |k, v| $evm.log("info", "LAN:<$evm.root> Attribute - #{k}: #{v}")}
    lans.each { |lan|
        lan.attributes.sort.each { |k, v| $evm.log("info", "LAN attributes:<$evm.root> Attribute - #{k}: #{v}")}
        lan.virtual_column_names.sort.each { |k, v| $evm.log("info", "LAN virtual column:<$evm.root> Attribute - #{k}: #{v}")}
        list_of_lans[lan.name]=lan.name
    }
    
    dialog_field = $evm.object
    # sort_by: value / description / none
    dialog_field["sort_by"] = "description"
    # sort_order: ascending / descending
    dialog_field["sort_order"] = "ascending"
    # data_type: string / integer
    dialog_field["data_type"] = "string"
    # required: true / false
    dialog_field["required"] = "true"

    dialog_field["values"]=list_of_lans
    

    # hosts = $evm.vmdb('host').all
    
    # hosts.each { |k, v| $evm.log("info", "Hosts:<$evm.root> Attribute - #{k}: #{v}")}

    # hosts.each { |host| 
    #     host.attributes.sort.each { |k, v| $evm.log("info", "host attributes:<$evm.root> Attribute - #{k}: #{v}")}
    #     host.virtual_column_names.sort.each { |k, v| $evm.log("info", "host virtual column:<$evm.root> Attribute - #{k}: #{v}")}
    # }

    #
    # Exit method
    #
    $evm.log("info", "EVM Automate Method Ended")
    exit MIQ_OK
  
    #
    # Set Ruby rescue behavior
    #
  rescue => err
    $evm.log("error", "[#{err}]\n#{err.backtrace.join("\n")}")
    exit MIQ_ABORT
  end
  
