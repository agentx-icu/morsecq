# MorseCQ offline split handover

See the current [README](../README.md), [architecture](architecture/OFFLINE_LEARNING.md), [build guide](operations/BUILD_AND_DEPLOY.md) and [test pyramid](testing/TEST_PYRAMID.md). Earlier trainer+chat plans are historical.

Implemented: local startup, no registration/identity/transport, confirmed durable local clear, three destinations, offline five-platform builds and gated draft Releases.

Before shipping: run required CI on the final commit, verify physical-device microphone/keying/haptics and local persistence, provide owner store signing and Apple notarization as needed.
