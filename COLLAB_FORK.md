# EasyTier v2.6.4 Collab no-TUN fork

This fork is based on upstream EasyTier commit
`8428a89d2dabc94c97d370ec607c6ca142473626` (`v2.6.4`). It exists only to
produce the Windows x86_64 headless no-TUN runtime used by dsh-collab.

The fork does not replace or modify EasyTier's networking protocol, peer
discovery, NAT traversal, relay, encryption, or RPC implementation. Its source
change removes the Windows runtime dependency on Npcap's `Packet.dll` by:

- replacing pnet's umbrella crate with a local re-export of its packet/base
  crates on Windows, so `pnet_datalink` is not linked;
- using the existing `network-interface` crate for Windows interface discovery;
- omitting the TUN and FakeTCP features from the Collab build profile.

The original full-feature EasyTier builds are out of scope for this fork. Use
upstream EasyTier for TUN, FakeTCP, GUI, or non-Windows distributions.

## Build and verify

On Windows with Rust 1.95 and Visual Studio C++ build tools:

```powershell
./collab/windows-no-tun/build.ps1
./collab/windows-no-tun/verify.ps1
```

The build script produces
`artifacts/easytier-windows-x86_64-v2.6.4-collab.1.zip`. The verification script
requires `dumpbin.exe`, rejects any `Packet.dll` dependency, and runs both
headless executables without Npcap present.

EasyTier remains licensed under LGPL-3.0. Distributions of this fork must
provide this complete modified source (or the exact upstream source plus the
fork patch), its license notices, and these build materials.
