reg query HKCU /s /f {BD07DDB9-1C61-4DCE-9202-A2BA1757CDB2}
<<<<<<< HEAD


reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce
reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices
reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunServices
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce
reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\TaskScheduler\Tasks
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\TaskScheduler\Tree
reg query HKEY_CLASSES_ROOT*\shellex\ContextMenuHandlers
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Firefox\Extensions
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Google\Chrome\Extensions
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows\AppInit_DLLs
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Notify
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
=======
reg query HKLM /s /f "svchost.exe -k LocalServiceNetworkRestricted -p"
>>>>>>> 0b330c99bebed1ab64845c1e2dc6ef5947b7bb5b
