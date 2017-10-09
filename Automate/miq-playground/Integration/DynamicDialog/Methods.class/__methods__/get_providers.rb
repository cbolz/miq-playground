#
#            Automate Method
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
  
    list = {}

    $evm.vmdb("ext_management_system").each { |ems|
        $evm.log("info", "Adding EMS with ID #{ems.id} and name #{ems.name} to the dialog")
        list[ems.id]=ems.name
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
  