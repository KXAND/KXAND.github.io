start clean.bat
start /min /w mshta vbscript:setTimeout("window.close()",2000)
start generateAndDeploy.bat
exit