$input_path = ‘C:\Users\amiller\Desktop\temp reporting\state street\incidents.xml’
$output_file = ‘C:\Users\amiller\Desktop\temp reporting\state street\output.txt’
$regex = ‘<ns2:violationtext>(.+?)</ns2:violationtext>’
$regex2 = ‘<ns2:violationtext>(.+?)</ns2:violationtext>’
select-string -Path $input_path -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }  -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value } > $output_file 