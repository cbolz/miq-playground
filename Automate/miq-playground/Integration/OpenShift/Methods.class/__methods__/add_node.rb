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

    def yaml_data(option)
        @task.get_option(option).nil? ? nil : YAML.load(@task.get_option(option))
    end
      
    def parsed_dialog_information
        dialog_options_hash = yaml_data(:parsed_dialog_options)
        #log(:info, "#{dialog_options_hash.inspect}")
        return dialog_options_hash[0]
    end
  
    # Dump all of root's attributes to the log
    $evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}
  
    random = (0...8).map { (65 + rand(26)).chr }.join
   
    $evm.log("info", "su - clouduser -c /home/clouduser/add_host_v2.sh &> /tmp/add_host-#{random}.log &")
    rc=system("su - clouduser -c /home/clouduser/add_host_v2.sh &> /tmp/add_host-#{random}.log &")
    $evm.log("info", "Return Code: #{rc.inspect}")
    if rc != true
        exit MIQ_ABORT
    end 

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
  