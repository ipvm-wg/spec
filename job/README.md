# IPVM Job Spec

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors
    
## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract


# 1 Motivation



# 2 IPLD


# 3 Acknowledgments





``` js
{
  type: "ipvm/job",
  version: "0.0.1",
  requestorDid: "did:key:zAlice",
  config: {
    run: "asap",
    maxGas: 4096,
    label: "fission/run_the_reports",
    authz: [ucan1, ucan2],
    visibility: "public",
    verification: {
      method: "ipvm/optimistic/zk",
      min: 1,
      replication: 2,
      referee: "ipns://abcdef"
    }
  },
  interfaces: {
    // ...
  },
  invocation: {
    type: "ipvm/wasm",
    executable: "Qm123456",
    inputs: [
        { x: "Qm123456" },
        { y: "Qmabcdef" },
        { z: "QmFooBar" },
        { 
          database: "dnslink://example.com",
          effect: "dnslink/resolve" 
        }
    ],
  },
  signature: "abcdef"
}
```
