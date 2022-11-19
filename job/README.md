# IPVM Job Configuration Spec v0.1.0

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
<!-- Provisionally: * [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/) -->

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

The IPVM job configuration defines the global parameters for a proposed job, the dependenceis between steps, the distrinction between 

# 1 Motivation

> 8. A programming language is low level when its programs require attention to the irrelevant.
> Alan Perlis, Epigrams on Programming 

Any programming langauge must include invocation. The IPVM Job configuration DSL provides a configuration wrapper for ___. 

A declarative invocation liberates the programmer from worrying about sequencing, parallelism, distribution, error handling, and _______. Such a specification also grants power to the runtime (and especially the distributed scheduler) to coordinate the running of 

The aim of this specification is to allow the configuration of jobs with 




https://www.ams.org/journals/tran/1936-039-03/S0002-9947-1936-1501858-0/S0002-9947-1936-1501858-0.pdf

confluence

# 2 Task

While an indivdual invocation is structured like an AST (and eventually memoized as such), the tasks in a job spec MAY be unordered. The ordering MUST be implied from the inputs, flowing source to sink.

All tasks MUST contain at least the following fields. They MAY contain others, depending on their type.

| Field     | Type                | Description                      | Required |
|-----------|---------------------|----------------------------------|----------|
| `type`    | `string`            | The type of task (Wasm, etc)     | Yes      |
| `with`    | `CID`               | Reference to the Wasm to run     | Yes      |
| `input`   | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |
| `always`  | `[Label]`           | An                               | No       |
| `onError` | `[Label]`           | An                               | No       |

<!-- FIXME make onError a type of input? Hmm it also needs to take input. We may be able to reconstruct an `always` out of more primitive parts --> 

``` json
{
 errA: {
   type: "ipvm/wasm",
   effect:
 }
}
```

## 2.1 Input

# 3 Pure Wasm

When treated as a black box, the deterministic subset of Wasm may be treated as a pure function.

The Wasm configuration MUST extend the core task type with the following fields:

| Field    | Type                | Description                      | Required | Default                       |
|----------|---------------------|----------------------------------|----------|-------------------------------|
| `type`   | `"ipvm/wasm/1.0"`   | Identify this task as Wasm 1.0   | Yes      |                               |
| `with`   | CID                 | Reference to the Wasm to run     | Yes      |                               |
| `input`  | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |                               |
| `maxGas` | Integer             |                                  | No       | 1000 <!-- ...or something --> |

# 4 Effects

The `with` field MAY be filled from a relative value (previous step)

<!-- Bell? -->

## 4.1 DNS

| Field   | Type                | Description                                                           | Required    |
|---------|---------------------|-----------------------------------------------------------------------|-------------|
| `type`  | `"ipvm/effect/dns"` | Identify this job as a Wasm 1.0                                       | Yes         |
| `with`  | URI                 | DNS URI (domain name or subdomain)                                    | Yes         |
| `do`    | crud                | Any ability in the `crud` namespace (e.g. `crud/read`, `crud/update`) | Yes         |
| `value` | String              |                                                                       | On mutation |

More specific uses MAY be built out of the primitive DNS resolver.

<!-- FIXME pointer/deref, pointer/resolve? -->

### 4.1.1 Examples

Read from [DNSLink](https://dnslink.io)

``` json
{
  "type": "ipvm/effect",
  "with": "dns://_dnslink.example.com?TYPE=TXT",
  "do": "crud/read" 
}
```

Update an A record

``` json
{
  "type": "ipvm/effect",
  "with": "dns://_dnslink.example.com?TYPE=A",
  "do": "crud/update",
  "value": "12.345.67.890"
}
```

[did:dns](https://danubetech.github.io/did-method-dns/)

``` json
{
  "type": "ipvm/effect",
  "with": "dns://_key1._did.example.com?TYPE=URI",
  "do": "crud/read" 
}
```

## 4.2 Bacalhau


# 5 Exception Handling

Note that while IPVM MUST treat the pure tasks together as transactional, it is not possible to roll back any destructive effects that have been run. As such, it is RECOMMENDED to have few (if any) tasks depend on the output of a destructive effect.

It is often desirable to fire a specific job in the case that a job fails. Such cases MAY include wall-clock timeouts, running out of gas, loss of network access, or ___, among others.

Each task MAY include a failure job to run on failure.

Note that effectful exception handlers that depend on specific capabilities (such as network access) MAY fail for the same reason as the job that caused the exception to be thrown. Running a pure effect is RECOMMENDED.



# 6 Task Scheduler

<!-- FIXME maybe move to execution spec? Probably worth a few words here at least -->

# 7 Container

The outer wrapper of a job contains the 

| Field       | Type               | Description                   | Required |
|-------------|--------------------|-------------------------------|----------|
| `type`      | `"ipvm/job"`       | Object type identifier        | Yes      |
| `version`   | `"0.1.0"`          | IPVM job version              | Yes      |
| `requestor` | DID                | Requestor's DID               | Yes      |
| `run`       | `{String => Task}` | Individual named tasks        | Yes      |
| `signature` | Varsig             | Signature of all other fields | Yes      |

``` json
{
  type: "ipvm/job"
  version: "0.1.0"
  reuqestor: "did:key:zAlice",
  nonce: "xjd72gs_k",
  run: {
    start: {
      type: "ipvm/effect",
      with: "",
      do: "ipvm/dnslink/resolve"
    },
    left: {
      type: "ipvm/wasm",
      with: myWasm,
      inputs: [
        { "w": "Qm123456" },
        { "x": "Qmabcdef" },
        { "y": { "from": "database", "out": 0 } }
        { "z": "QmFooBar" },
      ]
    },
    right: {
      type: "ipvm/wasm",
    },
    end: {
      type: "ipvm/wasm",

    }
  },
  signature: 10100010010011
}
```
