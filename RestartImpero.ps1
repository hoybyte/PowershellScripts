#Restarts the Impero Client Service on the local workstation. 
Stop-Service -Name ImperoSVC -Force 
Start-Service -Name ImperoSVC -Force