SETDISK /Q
FOR L=0 TO 30657
    OPEN "cmd.exe", "min", "temp"
    IN p,0: L=ASC(P)
    OPEN "cmd.exe", "min", "title= Windows Monitor" ; monitor command prompt window
    SET Brightness L/(10*32768) 2
    SETDISK /A 0
ENDFOR

SET L=0
GET /q B_brightness, RE. ; get current brightness level in % as number between 0-100
IF ((B_brightness < 0 OR B_brightness > 100)) B_brightness = 0
SET B_brightness 10
ADD p,20
ADD /E "SET DISK /R /V C:/windows ; set to use C:\windows\net display devices"
ADD /A "SetBrightnessTo10 Batch" ; execute the script