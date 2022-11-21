# IPVM Job Specification v0.1.0

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
* [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/) _(TODO: Provisionally!)_

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

An IPVM Job defines the global configuration for a proposed job, their individual tasks, dependencies between tasks, any required authorization, authentication, and so on. An IPVM Jobs is an envelope for both the configuration and content layers common to job specifications.

# 1 Introduction

The potential complexity of a fully distributed execution by potentially unknown peers is very high. IPVM Jobs reduce the number of possible states by forcing explicit handling of any dangerous effects. The IPVM Job spec is a declarative document that MAY be inspected, transmitted, logged, and negotiated. Unlike a system like WASI, there is a strict separation of effects from pure data, with no intermixing of computation with live pipes.

While capability sytems such as [UCAN](https://github.com/ucan-wg/spec/) include the information required to execute a job, they assume an established audience (which too ridig for negotiation), do not signal the _intent_ to execute, and do not include fields to configure settings for the actual runtime.

IPVM Jobs MUST be suitable for the proposal of jobs and negotiation with provuders on a discovery layer (ahead of credential delegation), execution on untrusted peer machines, and ___. Jobs SHOULD provide a sufficiently expressive base to build more complex models such as actors, event-driven systems, map-reduce, and so on.

## 1.1 Design Philosophy

> 8. A programming language is low level when its programs require attention to the irrelevant.
>
> — Alan Perlis, Epigrams on Programming 

While IPVM in aggregate is capable of executing arbitrary programs, individual IPVM Jobs are specified declaratively, and tasks workflows MUST be acyclic. Invocation in the decalarative style liberates the programmer from worrying about explicit sequencing, parallelism, memoization, distribution, and nontermination in a trustless settings. Such constraints also grants the runtime control and flexibility to schedule tasks in an efficient and safe manner.

These constraints impose specific practices. There is no first-class concept of persistent objects or loops. Loops, actors, vats, concurrent objects, and so on MAY be implemented on top of IPVM Jobs by enqueuing new jobs using the effect system (much like a [mailbox receive loop](https://www.erlang.org/doc/efficiency_guide/processes.html)).

The core restrictions enforced by the design of IPVM Jobs are:

1. Execution MUST terminate in finite time
2. Job tasks MUST form a partial order
3. Effects MUST be managed by the runtime and declared ahead of time

While effects MUST be declared up front, they MAY also be emitted as output from pure computation (see the core spec for more). This provides a "legal" escape hatch for building higher-level abstraction that incorporate effects.

## 1.2 Humane Design

> People are part of the system. The design should match the user's experience, expectations, and mental models.
>
> — Jerome Saltzer & M. Frans Kaashoek, Principles of Computer System Design

While higher-level interfaces over IPVM Jobs MAY be used, ultimately configuration is the UI at this level of abstraction. The core use cases are moving jobs and tasks between machines, logging, and execution.

IPVM Jobs aim to provide a computational model with a clear contract ("few if any surprises") for the programmer. 

IPVM jobs follow the [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration) philosophy with defaults and cascading configuration.

## 1.3 Security Considerations

> A program can create a controlled environment within which another, possible untrustworthy program, can be run safely [but] may leak, i.e., transmit [...] the input data which the customer gives it [...] We will call the problem of constraining a service [from leaking sensitive data] the confinement problem.
> 
> Butler W. Lampson, A Note on the Confinement Problem, Communications of the ACM

IPVM runs in trustless ("mutually suspicious") environments. Conceivably either a job proposer or service provider could be mallicious. To limit ___.

Working with encrypted data and application secrets (section X.Y) is common practice for many jobs. IPVM treats these as effects and affinities. As it is intended to operate on a public network, secrets MUST NOT be hardcoded into an IPVM Job. Any task that involves a dereferenced secret or decrypted data — including its downstream consumers — MUST be marked as secret and not distributed.

While it is tempting to push authorization concerns to a serapate layer, this has historically lead systems to be built on fundamentally insecure primitives. As such, IPVM Jobs include security considerations directly. It is not possible to control the security model of external effects, but it is possible to secure the inbound boundary to IPVM.

Pure computation is always allowed as long as it terminates in a fixed number of steps. An executor 

Shared-nothing architecture. Even if shared memory is used, it MUST be controlled externally via the effect system (i.e. an outside agent).

# 2 Envelope

The outer wrapper of a job contains the information 

FIXME add IPLD schema

| Field       | Type                        | Description                             | Required | Default |
|-------------|-----------------------------|-----------------------------------------|----------|---------|
| `type`      | `"ipvm/job"`                | Object type identifier                  | Yes      |         |
| `version`   | `"0.1.0"`                   | IPVM job version                        | Yes      |         |
| `requestor` | DID                         | Requestor's DID                         | Yes      |         |
| `nonce`     | String                      | Unique nonce                            | Yes      |         |
| `parent`    | `CID-relative Path or null` | The CID of the initiating task (if any) | No       | `null`  |
| `meta`      | Object                      |                                         | No       | `{}`    |
| `config`    | `IpvmConfig`                |                                         | No       |         |
| `run`       | `{String => Task}`          | Named tasks                             | Yes      |         |
| `exception` | `Task.Wasm`                 |                                         |          |         |
| `signature` | Varsig                      | Signature of serialized fields          | Yes      |         |

## 2.1 Fields

## 2.1.1 Type

The `type` field MUST be set to `ipvm/job`. This field together with the `version` field indicates the expected fields and minimal semantics for the job.

## 2.1.2 Version

The `version` field MUST be set to `0.1.0`. This field together with the `type` field indicates the expected fields and minimal semantics for the job.

## 2.1.3 Requestor

The `requestor` field MUST be set to the DID of the agent requesting the job. The Rquestor is the only identified agent in a Job.

The `signature` field MUST validate with a public key associated with the Requestor's DID.

## 2.1.4 Nonce

The `nonce` field MUST be a one-time-use random string. At least 12 random bytes encoded as base64 is RECOMMENDED.

## 2.1.5 Parent

The OPTIONAL `parent` field contains the CID of the IPVM Task that initiated it (if any).

## 2.1.6 Meta

The `meta` field contains a user-definable JSON object. This is useful for including things like tags, comments, and so on.

## 2.1.7 Global Configuration

The ___ FIXME

## 2.1.8 Run

The `run` field contains all of the IPVM Tasks set to run in this Job, each labelled by a human-readable key.

See the [Task](FIXME) section for more.

## 2.1.9 Exception

The `exception` field contains a Task with predefined inputs. See the [Exception Handling](FIXME) section for more.

## 2.1.10 Signature

The signature of the CID represented by the other fields.

## 2.2 Example

Here is a nontrivial example of two tasks (`left` and `right`) used as input to a third task (`end`).

``` json
{
  "type": "ipvm/job",
  "version": "0.1.0",
  "requestor": "did:key:zAlice",
  "nonce": "o3--8Gdu5",
  "tasks": {
    "left": {
      "type": "ipvm/wasm",
      "wasm/0.1.0": "bafyLeftWasm",
      "inputs": [],
      "outputs": ["a", "b"] <!-- FIXME component model instead? -->
    },
    "right": {
      "type": "ipvm/wasm",
      "wasm/0.1.0": "QmRightWasm",
      "inputs": [
        { "bar": "bafy123" }
      ],
      "outputs": ["a", "b"] 
    },
    "end": {
      "wasm": "QmEndWasm",
      "inputs": [
        { "a": { "from": "left" } },
        { "b": { "from": "right" } },
        { "c": 123 }
      ]
    }
  },
  "signature": "abcdef"
}
```

# 3 Tasks

While an indivdual invocation is structured like an AST (and eventually memoized as such), the tasks in a job spec MAY be unordered. Execution order MUST be determined by the scheduler and implied from the inputs.

All tasks MUST contain at least the following fields. They MAY contain others, depending on their type.

| Field    | Type                | Description                      | Required | Default |
|----------|---------------------|----------------------------------|----------|---------|
| `type`   | `string`            | The type of task (Wasm, etc)     | Yes      |         |
| `with`   | `CID or URI`        | Reference to the Wasm to run     | Yes      |         |
| `input`  | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |         |
| `auth`   | `UCAN[]`            |                                  | Yes      |         |
| `secret` | `Boolean`           | <!-- or publish? -->             | No       | `True`  |
| `meta`   | `Object`            |                                  | No       | `{}`    |

## 3.1 Fields

### 3.1.1 `type`

The `type` field is used to declare the shape of the objet. This field MUST be either `ipvm/wasm` for pure Wasm, or `ipvm/effect` for effectful computation.

### 3.1.2 `with` Resource

The `with` field MUST contain a CID or URI of the resource to interact with. For example, this MAY be the Wasm to execute, or the URL of a web server to send a message to.

### 3.1.3 `input`

FIXME define mapping to ABI / WIT

The `input` field contains an array of objects. Each entry represents an association of human-readable labels to values (or references to values). The index is significant, since many tasks take only positonal input.

Values MUST be serialized as ______. If an input is given as an object, it MUST be treated as 

For ex

# 4 Pure Wasm

Treated as a black box, the deterministic subset of Wasm MUST be treated as a pure function, with no additional handlers or other capabilities directly availabel via WASI or similar.

Since 
 
The Wasm configuration MUST extend the core task type with the following fields:

| Field     | Type                | Description                      | Required | Default                       |
|-----------|---------------------|----------------------------------|----------|-------------------------------|
| `type`    | `"ipvm/wasm"`       | Identify this task as Wasm 1.0   | Yes      |                               |
| `version` | `1.0`               | The Wasm module's Wasm version   | Yes      |                               |
| `with`    | CID                 | Reference to the Wasm to run     | Yes      |                               |
| `input`   | `[{String => CID}]` | Arguments to the Wasm executable | Yes      |                               |
| `maxgas`  | Integer             |                                  | No       | 1000 <!-- ...or something --> |

## 4.1 `type`

The `type` field declares this object to be an IPVM Wasm configuration. The value MUST be `ipvm/wasm`.

## 4.2 `with`

The `with` field declares the Wasm module to load via CID.

Note that the 

## 4.3 `input`

## 4.4 `maxgas`

The `maxgas` field specifies the upper limit in gas that this task may consume.

For the gas schedule, please see the [gas schedule spec].

# 5 Effects

The contract for effects is different from pure computation. As effects by definition interact with the "real world", 

The `with` field MAY be filled from a relative value (previous step)

| Field     | Type            | Description                    | Required    | Default |
|-----------|-----------------|--------------------------------|-------------|---------|
| `type`    | `"ipvm/effect"` | Identify this job as an effect | Yes         |         |
| `with`    | URI             |                                | Yes         |         |
| `do`      | `"crypto/sign"` |                                | Yes         |         |
| `value`   | String          |                                | On mutation |         |
| `timeout` | Integer         | Timeout in milliseconds        | No          | 1000    |

``` json
{
    "type": "ipvm/effect",
    "with": "did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4",
    "do": "crypto/sign",
    "inputs": [
        { "value": { "from": "earlierStep" } }
    ]
}
```

## 5.1 `type`

# 6 Exception Handler

Note that while IPVM MUST treat the pure tasks together as transactional, it is not possible to roll back any destructive effects that have been run. As such, it is RECOMMENDED to have few (if any) tasks depend on the output of a destructive effect.

It is often desirable to fire a specific job in the case that a job fails. Such cases MAY include wall-clock timeouts, running out of gas, loss of network access, or ___, among others. The exception handler fills a similar role to [GenServer.handle_info/2](https://hexdocs.pm/elixir/1.14.2/GenServer.html#c:handle_info/2).

Each task MAY include a failure job to run on failure.

Note that effectful exception handlers that emit effects (such as network access) MAY fail for the same reason as the job that caused the exception to be thrown. Running a pure value is RECOMMENDED.

# 7 Related Work and Prior Art

AWS Lambda job specs

E Language, CapNet

It is not possible to mention the separation of effects from computation without mentioning the algebraic effect lineage from Haskell, OCaml, and Eff. While the overall system looks quite different from the their type-level effects, this work owes a debt to at least Gordon Plotkin and John Power's work on [computational effects](https://homepages.inf.ed.ac.uk/gdp/publications/Overview.pdf), 

# 8 Acknowledgments

* Steb
* Mel
* Christine
* Blaine Cook
* Luke Marsden
