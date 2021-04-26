---
title: AMSI
---

# AMSI

This is the [Windows AntiMalware Scan Interface](https://docs.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal). This is basically an interface for scanning file, processes, and more that can then be used by Windows Defender or other antivirus products.

## Patching `AmsiScanBuffer`

It might be as easy as patching the `AmsiScanBuffer` function provided by `amsi.dll` to return false.

The basic process here is:
1. Use `LoadLibrary` to read `amsi.dll` from disk into a known variable handle.
1. Use `GetProcAddress` to identify the address of the `AmsiScanBuffer` function. Since `amsi.dll` should have already been loaded into the process at process start, this should be the address to the function already active in memory.
1. Use `VirtualProtect` to make the memory containing the `AmsiScanBuffer` function writable (0x40 == `PAGE_EXECUTE_READWRITE`).
1. Just copy over the byte code for a simple replacement function.

Replacement function:
```
b8 57 00 07 80          mov    eax,0x80070057 # AMSI_RESULT_CLEAN
c3                      ret
```

This replacement function is just two asm calls that push `AMSI_RESULT_CLEAN` into `eax` and return. This makes any call to `AmsiScanBuffer` succeed as if the file was clean.

### Powershell

In powershell, patching `AmsiScanBuffer` basically means calling out to a little C# code to do the heavy work of calling Win32 APIs to patch the function in the current process.

{{< details "Code" >}}
{{% code file="/content/docs/windows/evasion/powershell_rasta.ps1" language="powershell" %}}
{{< /details >}}

References:
- https://fatrodzianko.com/2020/08/25/getting-rastamouses-amsiscanbufferbypass-to-work-again/

### Nim

{{< details "Example" >}}
{{% code file="/content/docs/windows/evasion/nim_offensivenim.nim" language="nim" %}}
{{< /details >}}

## References
- https://onlinedisassembler.com/odaweb/majaEeX0/0
- https://docs.microsoft.com/en-us/windows/win32/memory/memory-protection-constants
- http://pinvoke.net/default.aspx/kernel32/VirtualProtect.html
