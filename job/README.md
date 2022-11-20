# IPVM Job Spec v0.1.0

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
<!-- Provisionally: * [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/) -->

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

The IPVM job configuration defines the global parameters for a proposed job, the dependenceis between steps, the distrinction between 

Any computing environment by defintion must include invocation. The IPVM Job configuration DSL provides configuration and dataflow for pure computation and effects.

# 1 Introduction

## 1.1 Motivation

## 1.2 Design Philosophy

> 8. A programming language is low level when its programs require attention to the irrelevant.
>
> — Alan Perlis, Epigrams on Programming 

While IPVM MAY execute arbitrary programs, IPVM Jobs are specified declaratively. Invocation in the decalarative style liberates the programmer from worrying about explicit sequencing, parallelism, memoization, and distribution. Such a specification also grants the runtime control and flexibility to schedule tasks in an efficient and safe manner.

On the other hand, IPVM Jobs are support few features and impose few constraints on what can be run. There is no first-class concept of persistent objects or loops. This layer of IPVM is only concerned with terminating execution. Loops, actors, vats, and so on MAY be implemented on top of IPVM Jobs by enqueuing new jobs using the effect system (much like a [mailbox receive loop](https://www.erlang.org/doc/efficiency_guide/processes.html)).

The core restrictions enforced by the design of IPVM Jobs are:

1. Execution MUST terminate in finite time
2. Job tasks MUST form a partial order
3. Effects MUST be managed by the runtime and declared ahead of time

While effects MUST be declared up front, they MAY also be emitted as output from pure computation (see the core spec for more). This provides a "legal" escape hatch for building higher-level abstraction that incorporate effects.

## 1.2 Humane Design

> People are part of the system. The design should match the user's experience, expectations, and mental models.
>
> — Jerome Saltzer & M. Frans Kaashoek, Principles of Computer System Design

While higher-level interfaces over IPVM Jobs MAY be used, ultimately configuration is the UI at this level of abstraction. The target is moving jobs and tasks between machines, logging, and debugging. As such IPVM jobs follow the [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration) philosophy with defaults and cascading configuration.

## 1.3 Security Considerations

Working with encrypted data and application secrets (section X.Y) is common practice for many jobs. IPVM treats these as effects and affinities. As it is intended to operate on a public network, secrets MUST NOT be hardcoded into an IPVM Job. Any task that involves a dereferenced secret or decrypted data — including its downstream consumers — MUST be marked as secret and never memoized.

# 2 Container

The outer wrapper of a job contains the 

configuration vs content layers

| Field       | Type               | Description                    | Required | Default |
|-------------|--------------------|--------------------------------|----------|---------|
| `type`      | `"ipvm/job"`       | Object type identifier         | Yes      |         |
| `version`   | `"0.1.0"`          | IPVM job version               | Yes      |         |
| `requestor` | DID                | Requestor's DID                | Yes      |         |
| `nonce`     | String             |                                | Yes      |         |
| `parent`    | `CID | null`       |                                | No       | `null`  |
| `meta`      | Object             |                                | No       | `{}`    |
| `config`    | `IpvmConfig`       |                                | No       |         |
| `run`       | `{String => Task}` | Named tasks                    | Yes      |         |
| `signature` | Varsig             | Signature of serialized fields | Yes      |         |

## 2.1 `type` Field

The `type` field MUST be set to `ipvm/job`.

...FIXME more text...

## 2.2 `version`

## 2.X Examples

### 2.X.1 Pure

Here is a nontrivial example of two tasks (`left` and `right`) used as input to a third task (`end`).

``` json
{
  "type": "ipvm/job",
  "version": "0.1.0",
  "requestor": "did:key:zAlice",
  "nonce": "o3--8Gdu5",
  "run": { 
    "left": {
      "type": "ipvm/wasm", // or make this a label for the microkernel?
      "kernel: "Qm12345", // Or here?
      "with": leftWasm,
      "inputs": [],
      "outputs": ["a", "b"] <!-- FIXME component model instead? -->
    },
    "right": {
      "type": "ipvm/wasm",
      "with": "rightWasm",
      "inputs": [
        { "bar": "bafy123" }
      ],
      "outputs": ["a", "b"] 
    },
    "end": {
      "type": "ipvm/wasm",
      "with": "QmEndWasm",
      "inputs": [
        { "a": { "from": "left" } },
        { "b": { "from": "right" } },
        { "c": 123 }
      ]
    }
  }
  "signature": "abcdef"
}
```

## 2.X.2 Effectful

Here is an example of a nontrivial IPVM job which reads from DNS, performs several jobs on the value, and atomically performs a DNS update with the output value.

``` json
{
  "type": "ipvm/job",
  "version": "0.1.0",
  "requestor": "did:key:zAlice",
  "nonce": "xjd72gs_k",
  "run": { <!-- alternate: run: { "ipvm/effects": {}, "ipvm/wasm": {}, "ipvm/exception": {} } -->
    "read-dns": {
      "type": "ipvm/effect",
      "with": "dns://_dnslink.example.com?TYPE=TXT",
      "do": "crud/read"
    },
    "check-dns": {
      "type": "ipvm/effect",
      "with": "dns://_dnslink.example.com?TYPE=TXT",
      "do": "crud/read"
      "inputs": [
        { "_": { "from": "end" } }
      ]
    },
    "write-dns": {
      "type": "ipvm/effect",
      "with": "dns://_dnslink.example.com?TYPE=TXT",
      "do": "crud/update",
      "inputs": [
        { "value": { "from": "end" } }
        { "_":     { "from": "cas" } }
      ],
      <!-- "await": [ "cas" ] ? -->
    }
    "left": {
      "type": "ipvm/wasm", // or make this a label for the microkernel?
      "kernel: "Qm12345", // Or here?
      "with": leftWasm,
      "inputs": [
        { "w": "Qm123456" },
        { "x": "Qmabcdef" },
        { "y": { "from": "read-dns" } }
        { "z": "QmFooBar" },
      ],
      "outputs": ["a", "b"] <!-- FIXME component model instead? -->
    },
    "right": {
      "type": "ipvm/wasm",
      "with": "rightWasm",
      "inputs": [
        { "foo": { "from": "read-dns/out" } },
        { "bar": "bafy123" }
      ],
      "outputs": ["a", "b"] 
    },
    "end": {
      "type": "ipvm/wasm",
      "with": "QmEndWasm",
      "inputs": [
        { "a": { "from": "left" } },
        { "b": { "from": "right" } },
        { "c": 123 }
      ]
    },
    "cas": {
      "type": "ipvm/wasm",
      "with": "cafyCasWasm",
      "inputs": [
        { "initial": "read-dns" },
        { "latest": "check-dns" }
      ]
    }
  },
  "exception": {
      "format-message": {
        type: "ipvm/wasm",
        with: handlerWasm
      }
  },
  "signature": "abcdef"
}
```

# 3 Task

While an indivdual invocation is structured like an AST (and eventually memoized as such), the tasks in a job spec MAY be unordered. The ordering MUST be implied from the inputs, flowing source to sink.

All tasks MUST contain at least the following fields. They MAY contain others, depending on their type.

| Field    | Type                | Description                      | Required | Default |
|----------|---------------------|----------------------------------|----------|---------|
| `type`   | `string`            | The type of task (Wasm, etc)     | Yes      |         |
| `with`   | `CID`               | Reference to the Wasm to run     | Yes      |         |
| `input`  | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |         |
| `auth`   | `UCAN[]`            |                                  | Yes      |         |
| `secret` | `Boolean`           | <!-- or publish? -->             | No       | `True`  |
| `meta`   | `Object`            |                                  | No       | `{}`    |

## 3.1 Input

# 4 Pure Wasm

When treated as a black box, the deterministic subset of Wasm may be treated as a pure function.
 
The Wasm configuration MUST extend the core task type with the following fields:

| Field    | Type                | Description                      | Required | Default                       |
|----------|---------------------|----------------------------------|----------|-------------------------------|
| `type`   | `"ipvm/wasm/1.0"`   | Identify this task as Wasm 1.0   | Yes      |                               |
| `with`   | CID                 | Reference to the Wasm to run     | Yes      |                               |
| `input`  | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |                               |
| `maxGas` | Integer             |                                  | No       | 1000 <!-- ...or something --> |

# 5 Effects

The `with` field MAY be filled from a relative value (previous step)

## 5.1 Secrets

Secrets MUST modelled as effects. Just as not every machine will have the ability to update a DNS record, not all will be able to decrypt data or sign data with a specific private key. These effects SHOULD default to private visibility.

### 5.1.1 Signing

| Field    | Type            | Description                     | Required    | Default |
|----------|-----------------|---------------------------------|-------------|---------|
| `type`   | `"ipvm/effect"` | Identify this job as a Wasm 1.0 | Yes         |         |
| `with`   | DID             |                                 | Yes         |         |
| `do`     | `"crypto/sign"` |                                 | Yes         |         |
| `value`  | String          |                                 | On mutation |         |
| `public` | `Boolean`       | RECOMMENDED not public          | Yes         | `false` |

<!-- NOTE: setting public: false will set all downstream to nonpublic as well, since they're now all tainted -->

``` json
{
    "type": "ipvm/effect",
    "with": "did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4",
    "do": "crypto/sign",
    "inputs": [{ "value": "aBcDeF" }]
}
```

### 5.1.2 Out-of-Band Decryption

``` json
{
    "type": "ipvm/effect",
    "with": "ipns://alice.fission.name/supersecret",
    "do": "crypto/decrypt",
    "public": false,
    "inputs": [{ "value": "aBcDeF" }]
}
```

### 5.1.3 In-Band Secrets

Some cases require having direct access to a secret, such as a

``` json
{
    "type": "ipvm/effect",
    "with": "ipvm:secret:github.com/ipvm-wg/spec?secret=API_KEY_NAME", <!-- FIXME reference GitHub API Key --> 
    "do": "secret/get", <!-- automatically set secret/get to public false and override with public: true, force: true? -->
    "public": false,
    "inputs": [{ "value": "aBcDeF" }]
}
```

## 5.2 DNS

| Field   | Type                | Description                                                           | Required    |
|---------|---------------------|-----------------------------------------------------------------------|-------------|
| `type`  | `"ipvm/effect/dns"` | Identify this job as a Wasm 1.0                                       | Yes         |
| `with`  | URI                 | DNS URI (domain name or subdomain)                                    | Yes         |
| `do`    | crud                | Any ability in the `crud` namespace (e.g. `crud/read`, `crud/update`) | Yes         |
| `value` | String              |                                                                       | On mutation |

More specific uses MAY be built out of the primitive DNS resolver.

<!-- FIXME pointer/deref, pointer/resolve? -->

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

## 5.3 IPNS

[IPNS](https://docs.ipfs.tech/concepts/ipns/)

``` json
{
  "type": "ipvm/effect",
  "with": "ipns://QmbCMUZw6JFeZ7Wp9jkzbye3Fzp2GGcPgC3nmeUjfVF87n",
  "do": "crud/read" 
}
```

<!-- warpforge, bacalhau -->

# 6 Exception Handler

Note that while IPVM MUST treat the pure tasks together as transactional, it is not possible to roll back any destructive effects that have been run. As such, it is RECOMMENDED to have few (if any) tasks depend on the output of a destructive effect.

It is often desirable to fire a specific job in the case that a job fails. Such cases MAY include wall-clock timeouts, running out of gas, loss of network access, or ___, among others.

Each task MAY include a failure job to run on failure.

Note that effectful exception handlers that depend on specific capabilities (such as network access) MAY fail for the same reason as the job that caused the exception to be thrown. Running a pure effect is RECOMMENDED.




---------



NOTE TO SELF: on `crud/read`, we probably need some kind of max file size limit (and timeout obvs)
