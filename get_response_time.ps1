if ($args.Length -ne 2)
{
  Write-Host "get_response_time.ps1  <URL>  <Interval>"
  Write-Host
  Write-Host  "  URL: URL"
  Write-Host  "  Interval: interval to check the response time [sec]"

  exit
}

$url = $Args[0]
$interval = $Args[1]
$out = "response_time.txt"
$err_out = "response_error.txt"

Write-Output "url = $url"
Write-Output "url = $url" >> $out
Write-Output "url = $url" >> $err_out
Write-Output ""
Write-Output "" >> $out
Write-Output "" >> $err_out

while ( 1 ){
  $date = date
  $restime = ""
  $ret = -1

  try{
    $restime = (Measure-Command -Expression { $site = Invoke-WebRequest -Uri $url -UseBasicParsing 2>> $err_out }).TotalMilliseconds
    $ret = $site.StatusCode.ToString()

    Write-Output "$date`t$restime`t$ret"
    Write-Output "$date`t$restime`t$ret" >> $out

  } catch {
    Write-Output "$date`terror`t$ret"
    Write-Output "$date`terror`t$ret" >> $err_out
  }

  Start-Sleep $interval
}
