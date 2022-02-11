$input_path = ‘C:\incidents.xml’
$output_file = ‘C:\output.txt’
$regex = ‘<ns2:violationtext>(.+?)</ns2:violationtext>’
#$regex2 = ‘<ns2:violationtext>(.+?)</ns2:violationtext>’
#select-string -Path $input_path -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }  -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value } > $output_file 
#Get-Content $input_path | Out-String | Select-String $regex -AllMatches | Select-Object - Expand Matches | ForEach-Object { $_.Groups[1].Value } | Set-Content $output_file

#select-string -Path $input_path -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Values } > $output_file
Get-Content $input_path | Out-String |
    Select-String $regex -AllMatches |
    Select-Object -Expand Matches |
    ForEach-Object { $_.Groups[1].Value } |
    Set-Content $output_file
