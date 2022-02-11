New-Item -ItemType Directory -Force -Path C:\Windows\Temp\scheduledtasks
$path = "c:\Windows\System32\Tasks"
$tasks = Get-ChildItem -recurse -Path $path -File
$Report = @()
 
foreach ($task in $tasks)
{
    $Details = "" | select Task, User, Enabled, Application, Arguments
    $AbsolutePath = $task.directory.fullname + "\" + $task.Name
    $TaskInfo = [xml](Get-Content $AbsolutePath)
    $Details.Task = $task.name
    $Details.User = $TaskInfo.task.principals.principal.userid
    $Details.Enabled = $TaskInfo.task.settings.enabled
    $Details.Application = $TaskInfo.task.actions.exec.command
    $Details.Arguments = $TaskInfo.task.actions.exec.Arguments
    $Details
    $Report += $Details
}
$Report |Export-Csv -Path 'C:\Windows\Temp\scheduledtasks\scheduledtasks.csv' -NoTypeInformation
echo "List of tasks available at C:\Windows\Temp\scheduledtasks\scheduledtasks.csv"