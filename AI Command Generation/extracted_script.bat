@echo off

powershell -Command "(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,20)"

echo Brightness set to 20%%.

pause