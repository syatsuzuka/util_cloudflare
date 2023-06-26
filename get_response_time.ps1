if ($args.Length -ne 3)
{
  Write-Host "get_response_time.ps1  <URL>  <Interval>  <Output>"
  Write-Host
  Write-Host  "  URL: URL"
  Write-Host  "  Interval: interval to check the response time [sec]"
  Write-Host  "  Output: output file name" 

  exit
}

$url = $Args[0]
$interval = $Args[1]
$output = $Args[2]

Write-Output "url = $url"
Write-Output "url = $url" > $output
Write-Output ""
Write-Output "" >> $output

while ( 1 ){
  $date = date
  $restime = (Measure-Command -Expression { $site = Invoke-WebRequest -Uri $url -UseBasicParsing }).Milliseconds

  Write-Output "$date`t$restime"
  Write-Output "$date`t$restime" >> $output

  Start-Sleep $interval
}