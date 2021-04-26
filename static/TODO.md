## Encode a bunch of files for powershell
```
for f in $(find www -type f -printf "%P\n"); do printf "[IO.File]::WriteAllBytes(\"c:\\inetpub\\wwwroot\\%s\", [Convert]::FromBase64String(\"%s\"))\n" "${f/\//\\}" "$(base64 -w 0 "www/$f")"; done
```

## Lockdown
```
vagrant winrm web1 -c 'net user vagrant /active:no'
```
