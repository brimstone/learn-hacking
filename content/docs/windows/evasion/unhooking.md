---
title: Unhooking EDR DLLs
---

# Unhooking EDR DLLs

Endpoint Detection and Response solutions are basically enhanced anti-virus products. They usually have a kernel driver watching the creation of processes then inject their own DLL into the process that then hooks a shim in place of functions loaded by other DLLs in order to detect malicious or unwanted programs based on their API calls.

A simple example is to hook `VirtualProtect` from `ntdll.dll` and watch for calls to set an area of memory `PAGE_EXECUTE_READWRITE` and if so, terminate the process. This is done with the [SylantStrike](https://github.com/CCob/SylantStrike) project.

"Unhooking" refers to mapping the original function call back to its original location and leaving the shim left in unreferenced memory.

## C#

{{< details "Example" >}}
{{% code file="windows/evasion/unhook_csharp.cs" language="c++" %}}
{{< /details >}}

## References
