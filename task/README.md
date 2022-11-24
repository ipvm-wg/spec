# IPVM Task Specification v0.1.0

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
* [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/) _(TODO: Provisionally!)_

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

Tasks are the smallest unit of work in an IPVM workflow. Each Task is restricted to a single type, such as Wasm or effects like an HTTP `GET` request. 

# 1 Introduction

Tasks describe everything required to execute the job. While all Tasks share some things in common, the details MAY be quite different.

Tasks can be broken into categories:

1. Pure
2. Effectful
    * Destructive
    * Nondestructive 

Where a pure function takes inputs to outputs, deterministically, without producing any other change to the world (aside from turning energy into heat).

Effects interact with the world in some way . Reading from a database, sending an email, and firing missiles are all kinds of effect.

One way to represent the difference between these pictorally is with box-and-wire diagrams. Here computation is drawn as a box. Explicit input and output are drawn as horizontal arrows, with input on the left and output on the right. Effects are drawn as vertical-pointing arrows.

```
 Safe
  │              ┌─                               ─┐
  │              │         ┌─────────────┐         │
  │              │         │             │         │
  │              │         │             │         │
  │         Pure │   ──────►             ├────►    │
  │              │         │             │         │
  │              │         │             │         │
  │              │         └─────────────┘         │
  │              └─                                │
  │                                                │
  │                                                │
  │                                                │ Nondestructive
  │                                                │
  │                                                │
  │              ┌─                                │
  │              │     │   ┌─────────────┐         │
  │              │     └───►             │         │
  │              │         │             │         │
  │              │   ──────►             ├────►    │
  │              │         │             │         │
  │              │         │             │         │
  │              │         └─────────────┘         │
  │              │                                ─┘
  │              │
  │              │
  │    Effectful │
  │              │
  │              │
  │              │                          ▲     ─┐
  │              │         ┌─────────────┐  │      │
  │              │         │             ├──┘      │
  │              │         │             │         │
  │              │   ──────►             ├────►    │ Destructive
  │              │         │             │         │
  │              │         │             │         │
  │              │         └─────────────┘         │
  ▼              └─                               ─┘
Unsafe
```

## 1.1 Pure Functions

Pure functions are very safe and simple. They can be retried safely, and their output is directly verifiable against other executions. Once a pure function has been accepted, it can be cached with an infinite TTL. The output of a pure function is fully equivalent to the invocation of the function and its arguments.

## 1.2 Nondestructive Effects

For the pureposes of IPVM, nondestructive effects are modelled as coming from "the world", and can be treated as input. They are not pure, because they depend on things outside of the workflow such as read-only state and nondeterminsm. Since they are not guaranteed reproducable, they can change from one request to the next. While this kind of effect They can be thought of as "read only", since they only report from outside source, but do not change it.

Nondestructive effects can be retried or raced safely. Each nondestructive invocation is unique, and need to be attested from a trusted source. Once their value enters the IPVM system, it is treated as a pure value.

## 1.3 Destructive Effects

Destructive effects are the opposite: they "update the world". Sending an text message cannot be retried without someone noticing a second text message. Destructive effects require careful handling, with attestation from the executor. Ensuring exact-once execution of destructive effects requires consensus on the execution schedule of the one task, which often incurs a performance penalty over other forms of task.

# 2 Envelope


All tasks MUST contain at least the following fields. They MAY contain others, depending on their type.

| Field     | Type      | Description                  | Required | Default   |
|-----------|-----------|------------------------------|----------|-----------|
| `type`    | `string`  | The type of task (Wasm, etc) | Yes      |           |
| `version` | SemVer    |                              | No       | `"0.1.0"` |
| `auth`    | `&UCAN[]` |                              | No       | `[]`      |
| `secret`  | `Boolean` | <!-- or publish? -->         | No       | `False`   |
| `meta`    | `Object`  |                              | No       | `{}`      |

## 2.1 Fields

### 2.1.1 `type`

The `type` field is used to declare the shape of the objet. This field MUST be either `ipvm/wasm` for pure Wasm, or `ipvm/effect` for effectful computation.

### 2.1.2 `with` Resource

The `with` field MUST contain a CID or URI of the resource to interact with. For example, this MAY be the Wasm to execute, or the URL of a web server to send a message to.

### 2.1.3 `args`

FIXME define mapping to ABI / WIT

The `input` field contains an array of objects. Each entry represents an association of human-readable labels to values (or references to values). The index is significant, since many tasks take only positonal input.

Values MUST be serialized as ______. If an input is given as an object, it MUST be treated as 

For ex




# 3 Pure Wasm

Treated as a black box, the deterministic subset of Wasm MUST be treated as a pure function, with no additional handlers or other capabilities directly availabel via WASI or similar.

Since 
 
The Wasm configuration MUST extend the core task type with the following fields:

| Field     | Type                | Description                      | Required | Default                       |
|-----------|---------------------|----------------------------------|----------|-------------------------------|
| `type`    | `"ipvm/wasm"`       | Identify this task as Wasm 1.0   | Yes      |                               |
| `version` | SemVer              | The Wasm module's Wasm version   | No       | `"0.1.0"`                     |
| `run`     | CID                 | Reference to the Wasm to run     | Yes      |                               |
| `args`    | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |                               |
| `secret`  | Boolean             |                                  | No       | `False`                       |
| `maxgas`  | Integer             | Maximum gas for the invocation   | No       | 1000 <!-- ...or something --> |

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
