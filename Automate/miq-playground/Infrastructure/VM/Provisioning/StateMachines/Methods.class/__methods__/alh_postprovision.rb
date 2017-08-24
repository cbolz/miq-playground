#
# alh_postprovision.rb
#

# Get provisioning object
#
prov = $evm.root['miq_provision']

#alh_ae_umgebung          = prov.get_option(:dialog_alh_ae_umgebung)
#alh_requester_name       = prov.get_option(:dialog_requester_name)
#alh_mail_address         = prov.get_option(:dialog_mail_address)
#alh_kundengruppe         = prov.get_option(:dialog_alh_kundengruppe)
#alh_linux_lifecycle_name = prov.get_option(:dialog_alh_linux_lifecycle_name)

vm = prov.vm

#vm.tag_assign("alh_linux_lifecycle/#{alh_linux_lifecycle_name}")


#destination = $evm.root['service_template_provision_task'].destination
#vmnamelist = ''
#destination.vms.each.do |vm|
#  if vmnamelist == ''
#    vmnamelist = vm.name.to_s
#  else
#    vmnamelist = vmnamelist + ' ' + vm.name.to_s
#  end
#  $evm.log('info', "vmnamelist = #{vmnamelist}")
#end
#
#destination.name = vmnamelist
#
#destination.tag_assign('alh_ae_umgebung
#                       alh_kundengruppe
#                       alh_linux_lifecycle_name

exit MIQ_OK
