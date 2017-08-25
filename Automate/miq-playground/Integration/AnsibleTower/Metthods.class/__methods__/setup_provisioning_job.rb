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
  
    prov = $evm.root["miq_provision"]
    
    job_template_name = $em.object['provisioning_job_template_name']

    # check on which provider we're running - if it's not in Testnetz (aka RHVMT) we remove '-testnetz'
    providerid = prov.get_option(:src_ems_id)
    provider = $evm.vmdb("ext_management_system").find_by_id(providerid)
    $evm.log("info", "Using provider: #{provider.inspect}")
    if not provider.name.include?("RHVMT")
      # remove substring '-testnetz' from the playbook name
      job_template_name = $evm.object['provisioning_job_template_name'].gsub('-testnetz','')
      $evm.log("info", "Looks like this is NOT our Testnetz Provider, removing -testnetz from the playbook name")
    end

    $evm.log("info", "Setting job_template_name to #{job_template_name} in provisioning options")
    prov.set_option(:dialog_job_template_name, job_template_name)

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