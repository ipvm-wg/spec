# IPVM Task Specification v0.1.0

> With hands of iron, there's not a task we couldn't do
>
> The Good Doctor, [The Protomen](https://en.wikipedia.org/wiki/The_Protomen)

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
* [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/)

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

Tasks are the smallest unit of negotiated work in an IPVM workflow. Each Task is restricted to a single type, such as a Wasm module, or effects like an HTTP `GET` request.

# 1 Introduction

Tasks describe everything required to the negotate the of work. While all Tasks share some things in common, the details MAY be quite different.

IPVM Tasks are defined as a subtype of [UCAN Actions](https://github.com/ucan-wg/invocation/blob/rough/README.md#32-ipld-schema). Tasks require certain fields in the `inputs` field to configure IPVM for timeouts, gas usage, credits, transactional guarantees, result visibility, and so on.

## 2 Effects

Tasks can be broken into categories:

1. Pure
2. Effectful
    * Destructive
    * Nondestructive 

Where a pure function takes inputs to outputs, deterministically, without producing any other change to the world (aside from [heat](https://en.wikipedia.org/wiki/Second_law_of_thermodynamics)).

Effects interact with the world in some way . Reading from a database, sending an email, and firing missiles are all kinds of effect.

One way to represent the difference between these pictorally is with box-and-wire diagrams. Here computation is drawn as a box. Explicit input and output are drawn as horizontal arrows, with input on the left and output on the right. Effects are drawn as vertical-pointing arrows.

```
 Safe
  ▲             ┌─                                         ─┐
  │             │                    ┌─────────────┐        │
  │             │                    │             │        │
  │             │                    │             │        │
  │        Pure │              ──────►             ├────►   │
  │             │                    │             │        │
  │             │                    │             │        │
  │             │                    └─────────────┘        │
  │             └─                                          │
  │                                                         │
  │                                                         │
  │                                                         │ Nondestructive
  │                                                         │
  │                                                         │
  │             ┌─         ┌─                               │
  │             │          │     │   ┌─────────────┐        │
  │             │          │     └───►             │        │
  │             │          │         │             │        │
  │             │    Query │   ──────►             ├────►   │
  │             │          │         │             │        │
  │             │          │         │             │        │
  │             │          │         └─────────────┘        │
  │             │          └─                              ─┘
  │             │
  │             │
  │   Effectful │
  │             │
  │             │
  │             │          ┌─                         ▲    ─┐
  │             │          │         ┌─────────────┐  │     │
  │             │          │         │             ├──┘     │
  │             │          │         │             │        │
  │             │  Command │   ──────►             ├────►   │ Destructive
  │             │          │         │             │        │
  │             │          │         │             │        │
  │             │          │         └─────────────┘        │
  ▼             └─         └─                              ─┘
Unsafe
```

FIXME safety level MUST be defined by the pair `(URI Scheme, Ability)` (service metadata). This may need a field on the workflow.

## 2.1 Pure Functions

Pure functions are very safe and simple. They can be retried safely, and their output is directly verifiable against other executions. Once a pure function has been accepted, it can be cached with an infinite TTL. The output of a pure function is fully equivalent to the invocation of the function and its arguments.

Note that in IPVM, pre-resolved CID handles are treated as referentially transparent. See [CID Handles](FIXME).

## 2.2 Nondestructive Effects

For the pureposes of IPVM, nondestructive effects are modelled as coming from "the world", and can be treated as input. They are not pure, because they depend on things outside of the workflow such as read-only state and nondeterminsm. Since they are not guaranteed reproducable, they can change from one request to the next. While this kind of effect They can be thought of as "read only", since they only report from outside source, but do not change it.

Nondestructive effects can be retried or raced safely. Each nondestructive invocation is unique, and need to be attested from a trusted source. Once their value enters the IPVM system, it is treated as a pure value.

## 2.3 Destructive Effects

Destructive effects are the opposite: they "update the world". Sending an text message cannot be retried without someone noticing a second text message. Destructive effects require careful handling, with attestation from the executor. Ensuring exact-once execution of destructive effects requires consensus on the execution schedule of the one task, which often incurs a performance penalty over other forms of task.

# 3 Content Handles

FIXME This probably belongs in its own spec. Now that we have the basic concept, it keeps coming up in conversation.

[Content Identifiers](https://docs.ipfs.tech/concepts/content-addressing/) (CIDs) are integral to IPFS. They map a hash to its preimage, which is a stable identifier for it across all machines, liberating it from location. However, this does not guarantee that the CID is resolvable at a particular time or place.

A Content Handle (CHa) is a type that MUST only be created by the runtime and MUST NOT have a serializated representation. This special handling provides a [lightweight proof](https://kataskeue.com/gdp.pdf) that the content is reachable to downstream tasks, allowing the scheduler to treat it as a pure value. A failure to dereference content from a CHa is a failure of the runner, not the requestor. By analogy to HTTP, failing to resolve a CHa is a 500, passing a malformed CID is a 400, and the effect converting a CID to a CHa timing out is a 408.

This  that the CID has been checked, and the runner guarintees that it is available in the current environment.

NOTE TO SELF: should CHa be its own spec? Seems useful :thinking:

| Issue                         | At Fault               |
|-------------------------------|------------------------|
| Malformed CID                 | Requestor              |
| Cannot provide all CHa blocks | Runner                 |
| Cannot resolve CID to CHa     | Network or Environment |

``` js
// Just a sketch for now, don't judge me!
{
  "type": "ipvm/effect",
  "version": "0.1.0",
  "using": "cid:Qm12345",
  "do": "handle/resolve"
}
```

```haskell
-- No, this won't survive into the fnal draft. Just stashing it here for now as a note!
resolve :: CID -> IO (Either Timeout CHa)
```

# 2 Envelope

An IPVM Task MUST be embedded inside of a [UCAN Action](https://github.com/ucan-wg/invocation)'s `inputs` field. As such, the URI and command to be run are handled at the Action layer. 

``` ipldsch
type Action struct {
  using  URI
  do     Ability
  input  Any
  
  -- IPVM Specific
  config TaskConfig (implicit {}) 
}

type TaskConfig struct {
  v      SemVer
  secret Boolean (implicit False)
  check  Verification
}

type Verification struct {
  | Attestation
  | Consensus(Integer)
  | Optimistic(Integer)
  | ZKP(ZeroKnowledge)
}

type Optimistic struct {
  confirmations Integer
  referee Referee
}

type Referee enum {
  | ZK(ZeroKnowledge)
  | Trusted(URI)
}

type ZeroKnowledge enum {
  | Groth16
  | Nova
  | Nova2
}
```

All tasks MUST contain at least the following fields. They MAY contain others, depending on their type.

| Field    | Type                   | Description                             | Required | Default |
|----------|------------------------|-----------------------------------------|----------|---------|
| `v`      | SemVer                 | IPVM Task Version                       | Yes      |         |
| `secret` | `Boolean or null`      | Whether the output is unsafe to publish | No       | `null`  |
| `check`  | `Verification or null` |                                         |          |         |

## 2.1 IPLD Schema

``` ipldsch
type TaskConfig struct {
  secret nullable optional Boolean
}
```

## 2.2 JSON Examples

``` json
{
  "using": "dns://example.com?TYPE=TXT",
  "do": "crud/update",
  "inputs": { 
     "value": "hello world"
  },
  "ipvm/config": {
    "v": "0.1.0",
    "secret": false,
    "timeout": { "ms": 5000 },
    "retries": 5,
    "verification": 
  }
}
```

## 2.1 Fields

### 2.1.1 `secret`

The `secret` flag marks a task as being unsuitable for publication.

If the `sceret` field is explicitely set, the task MUST be treated per that setting. If not set, the `secret` field defaults to `null`, which behaves as a soft `false`. If such a task consumes input from a `secret` source, it is also marked as `secret`.

Note: there is no way to enforce secrecy at the task-level, so such tasks SHOULD only be negotiated with runners that are trusted. If secrecy must be inviolable, consider using [multi-party computation (MPC)](https://en.wikipedia.org/wiki/Secure_multi-party_computation) or [fully homomorphic encryption (FHE)](https://en.wikipedia.org/wiki/Homomorphic_encryption#Fully_homomorphic_encryption) inside the task.

# 3 Pure Wasm

Treated as a black box, the deterministic subset of Wasm MUST be treated as a pure function, with no additional handlers or other capabilities directly available via WASI or similar aside from the ability to read content addressed data.

Note that while the function itself is pure, as is dereferencing content-addressed data, the function MAY fail if the CID is not available to the runner.

The Wasm configuration MUST extend the core task type as follows:

| Field     | Type                  | Description                               | Required | Default                       |
|-----------|-----------------------|-------------------------------------------|----------|-------------------------------|
| `type`    | `"ipvm/wasm"`         | Identify this task as Wasm 1.0            | Yes      |                               |
| `version` | SemVer                | The Wasm module's Wasm version            | No       | `"0.1.0"`                     |
| `mod`     | CID                   | Reference to the Wasm module to run       | Yes      |                               |
| `fun`     | `String or OutputRef` | The function to invoke on the Wasm module | Yes      |                               |
| `args`    | `[{String => CID}]`   | Arguments to the Wasm executable          | Yes      |                               |
| `secret`  | Boolean               |                                           | No       | `False`                       |
| `maxgas`  | Integer               | Maximum gas for the invocation            | No       | 1000 <!-- ...or something --> |

## 3.1 `type`

The `type` field declares this object to be an IPVM Wasm configuration. The value MUST be `ipvm/wasm`.

## 3.2 `with`

The `with` field declares the Wasm module to load via CID.

Note that the 

## 3.3 `input`

## 3.4 `maxgas`

The `maxgas` field specifies the upper limit in gas that this task may consume.

For the gas schedule, please see the [gas schedule spec].

# 4 Effects

The contract for effects is different from pure computation. As effects by definition interact with the "real world". These may be either commands or queries. Exmaples of effects include reading from DNS, sending an HTTP POST request, running a WASI module with network access, or receieving a random value.

The `with` field MAY be filled from a relative value (previous step)

| Field     | Type            | Description                         | Required | Default |
|-----------|-----------------|-------------------------------------|----------|---------|
| `type`    | `"ipvm/effect"` | Identify this workflow as an effect | Yes      |         |
| `version` | SemVer          | IPVM effect schema version          | No       | `0.1.0` |
| `using`   | URI             |                                     | Yes      |         |
| `do`      | ability         |                                     | Yes      |         |
| `args`    | `[{}]`          |                                     | No       | `[]`    |
| `timeout` | Integer         | Timeout in milliseconds             | No       | `5000`  |
| `auth`    | `[&UCAN]`       |                                     | No       | `[]`    |

<!-- | `destructive` | Boolean         |  FIXME infer from `do` field?  | No       | `True`  | -->
<!-- indeed these need to be registered by the runner -->

``` json
{
    "type": "ipvm/effect",
    "to": "did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4",
    "do": "crypto/sign",
    "args": [
        { "value": { "from": "earlierStep" } }
    ]
}
```

## 4.1 `type`


 ``` json
{
  "using": "wasm:Qm12345"
  "do": "ipvm/call",
  "args": {
    "type": "ipvm/wasm",
    "version": "0.1.0",
    "fun": "add_one",
    "args": [1, 2, 3],
    "maxgas": 1024
  }
}
```

``` json
{
  "type": "ipvm/effect",
  "version": "0.1.0",
  "using": "docker:Qm12345"
  "meta": {
    "description": "Tensorflow container",
    "tags": ["machine-learning", "tensorflow", "myproject"]
  },
  "after": ["previousStep", "QmXYZ"] // Contraint on effect ordering, as opposed to using the inputs directly
  "do": {
    "resources": {
      "ram": {"gb": 10}
    },
    "inputs": [1, 2, 3],
    "entry": "/",
    "workdir": "/",
    "env": {
      "$FOO": "bar"
    },
    "timeout": {"seconds": "3600"},
    "contexts": [],
    "output": [],
    "sharding": 5
  }
}
```

# 5 Prior Art

* [Bacalhau Job (Alpha)](https://github.com/filecoin-project/bacalhau/blob/8568239299b5881bc90e3d6be2c9aa06c0cb3936/pkg/model/job.go#L113-L126)
* [BucketVM](https://purrfect-tracker-45c.notion.site/bucket-vm-73c610906fe44ded8117fd81913c7773)
* [UCAN Invocation](https://github.com/ucan-wg/invocation)
* [WarpForge Formula](https://github.com/warptools/warpforge/blob/master/examples/100-formula-parse/example-formulas.md)

# 6 Acknowledgments


NOTE TO SELFL inputs as "ports"
