start /min /w mshta vbscript:setTimeout("window.close()",1000)
echo the input is %1
set name=%1
echo %name%
start /d "C:\Users\uftx\AppData\Local\Programs\Microsoft VS Code\" Code.exe "D:\Users\uftx\Documents\hexo\source\_drafts\%name%.md"