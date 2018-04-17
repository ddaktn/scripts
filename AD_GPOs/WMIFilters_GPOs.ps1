### WMI filter for Windows 10 and Windows Server 2016 machines

SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.%"

### WMI filter for JUST Windows 10

SELECT * FROM win32_OperatingSystem WHERE Version LIKE "10.%" AND ProductType="1"

### WMI filter for JUST Windows Server 2016

SELECT * FROM win32_OperatingSystem WHERE Version LIKE "10.%" AND ProductType="3"

### WMI filter for ALL desktop/client machines

SELECT * FROM win32_OperatingSystem WHERE ProductType="1"

### WMI filter for ALL server machines

SELECT * FROM win32_OperatingSystem WHERE ProductType="3"

### WMI filter for ALL domain controllers

SELECT * FROM win32_OperatingSystem WHERE ProductType="2"

### WMI filter for ALL NON-DOMAIN CONTROLLERS

SELECT * FROM win32_OperatingSystem WHERE ProductType="1" OR ProductType="3"

