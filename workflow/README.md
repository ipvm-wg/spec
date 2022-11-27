# IPVM Workflow Specification v0.1.0

> In late 1970 or early ’71 I approached IBM Canada’s Intellectual Property department to see if we could take out a patent on the basic idea [of dataflow]. Their recommendation, which I feel was prescient, was that this concept seemed to them more like a law of nature, which is not patentable. 
>
> J. Paul Morrison, [Flow-Based Programming](https://jpaulm.github.io/fbp/book.html)

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
* [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/) _(TODO: Provisionally!)_

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

An IPVM Workflow defines the global configuration for a proposed workflow, their individual tasks, dependencies between tasks, any required authorization, authentication, and so on. An IPVM Workflows is an envelope for both the configuration and content layers common to declarative workflow specifications.

# 1 Introduction

The potential complexity of a fully distributed execution by potentially unknown peers is very high. IPVM Workflows reduce the number of possible states by forcing explicit handling of any dangerous effects. The IPVM Workflow spec is a declarative document that MAY be inspected, transmitted, logged, and negotiated. Unlike a system like WASI, there is a strict separation of effects from pure data, with no intermixing of computation with live pipes.

While capability sytems such as [UCAN](https://github.com/ucan-wg/spec/) include the information required to execute a workflow, they assume an established audience (which too ridig for negotiation), do not signal the _intent_ to execute, and do not include fields to configure settings for the actual runtime.

IPVM Workflows MUST be suitable for the proposal of workflows and negotiation with provuders on a discovery layer (ahead of credential delegation), execution on untrusted peer machines, and ___. Workflows SHOULD provide a sufficiently expressive base to build more complex models such as actors, event-driven systems, map-reduce, and so on.

## 1.1 Design Philosophy

> 8. A programming language is low level when its programs require attention to the irrelevant.
>
> — Alan Perlis, Epigrams on Programming 

While IPVM in aggregate is capable of executing arbitrary programs, individual IPVM Workflows are specified declaratively, and tasks workflows MUST be acyclic. Invocation in the decalarative style liberates the programmer from worrying about explicit sequencing, parallelism, memoization, distribution, and nontermination in a trustless settings. Such constraints also grants the runtime control and flexibility to schedule tasks in an efficient and safe manner.

These constraints impose specific practices. There is no first-class concept of persistent objects or loops. Loops, actors, vats, concurrent objects, and so on MAY be implemented on top of IPVM Workflows by enqueuing new workflows using the effect system (much like a [mailbox receive loop](https://www.erlang.org/doc/efficiency_guide/processes.html)).

The core restrictions enforced by the design of IPVM Workflows are:

1. Execution MUST terminate in finite time
2. Workflow tasks MUST form a partial order
3. Effects MUST be managed by the runtime and declared ahead of time

While effects MUST be declared up front, they MAY also be emitted as output from pure computation (see the core spec for more). This provides a "legal" escape hatch for building higher-level abstraction that incorporate effects.

## 1.2 Humane Design

> People are part of the system. The design should match the user's experience, expectations, and mental models.
>
> — Jerome Saltzer & M. Frans Kaashoek, Principles of Computer System Design

While higher-level interfaces over IPVM Workflows MAY be used, ultimately configuration is the UI at this level of abstraction. The core use cases are moving workflows and tasks between machines, logging, and execution. IPVM Workflows aim to provide a computational model with a clear contract ("few if any surprises") for the programmer, while limiting verbosity. IPVM workflows follow the [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration) philosophy with defaults and cascading configuration.

## 1.3 Security Considerations

> A program can create a controlled environment within which another, possible untrustworthy program, can be run safely [but] may leak, i.e., transmit [...] the input data which the customer gives it [...] We will call the problem of constraining a service [from leaking sensitive data] the confinement problem.
> 
> Butler W. Lampson, A Note on the Confinement Problem, Communications of the ACM

IPVM runs in trustless ("mutually suspicious") environments. Conceivably either a workflow proposer or service provider could be mallicious. To limit ___.

Working with encrypted data and application secrets (section X.Y) is common practice for many workflows. IPVM treats these as effects and affinities. As it is intended to operate on a public network, secrets MUST NOT be hardcoded into an IPVM Workflow. Any task that involves a dereferenced secret or decrypted data — including its downstream consumers — MUST be marked as secret and not distributed.

While it is tempting to push authorization concerns to a serapate layer, this has historically lead systems to be built on fundamentally insecure primitives. As such, IPVM Workflows include security considerations directly. It is not possible to control the security model of external effects, but it is possible to secure the inbound boundary to IPVM.

Pure computation is always allowed as long as it terminates in a fixed number of steps. An executor 

Shared-nothing architecture. Even if shared memory is used, it MUST be controlled externally via the effect system (i.e. an outside agent).

# 2 Envelope

The outer wrapper of a workflow MUST contain the following fields:

| Field          | Type                        | Description                               | Required | Default |
|----------------|-----------------------------|-------------------------------------------|----------|---------|
| `type`         | `"ipvm/workflow"`           | Object type identifier                    | Yes      |         |
| `version`      | `"0.1.0"`                   | IPVM workflow version                     | Yes      |         |
| `requestor`    | DID                         | Requestor's DID                           | Yes      |         |
| `nonce`        | String                      | Unique nonce                              | Yes      |         |
| `verification` | `{"optimistic": 2} or null` |                                           | Yes      |         |
| `meta`         | `&Object`                   | User-defined object (tags, comments, etc) | No       | `{}`    |
| `parent`       | `CID-relative Path or null` | The CID of the initiating task (if any)   | No       | `null`  |
| `defaults`     | `IpvmConfig`                |                                           | No       | `{}`    |
| `tasks`        | `{String => Task}`          | Named tasks                               | Yes      |         |
| `exception`    | `Task.Wasm`                 |                                           | No       | `null`  |
| `signature`    | Varsig                      | Signature of serialized fields            | Yes      |         |

``` ipldsch
FIXME

type Workflow struct {
  ver String
  req DID
  nnc String 
  vfy Verification 
  meta &{String:String} implicit {}
  par &Task optional nullable
  dfl Config implicit {}
  tsks {String: Task}
  exc &Wasm optional nullable
  sig
}

type Verification union {
  | OptimisticVerification
  | "snark"
} representation keyed

type OptimisticVerification struct {
  optimistic Integer
}
```

## 2.1 Fields

## 2.1.1 Type

The `type` field MUST be set to `ipvm/workflow`. This field together with the `version` field indicates the expected fields and minimal semantics for the workflow.

## 2.1.2 Version

The `version` field MUST be set to `0.1.0`. This field together with the `type` field indicates the expected fields and minimal semantics for the workflow.

## 2.1.3 Requestor

The `requestor` field MUST be set to the DID of the agent requesting the workflow. The Rquestor is the only identified agent in a Workflow.

The `signature` field MUST validate with a public key associated with the Requestor's DID.

## 2.1.4 Nonce

The `nonce` field MUST be a one-time-use random string. At least 12 random bytes encoded as base64 is RECOMMENDED.

## 2.1.5 Parent

The OPTIONAL `parent` field contains the CID of the IPVM Task that initiated it (if any).

## 2.1.6 Meta

The `meta` field contains a user-definable JSON object. This is useful for including things like tags, comments, and so on.

<!-- FIXME is this an attack vector? We should force this to be a CID I guess? -->

## 2.1.7 Defaults

The global `defaults` object (FIXME section X.Y) sets the configuration for the workflow itself, and defaults for tasks.
 
## 2.1.8 Run

The `run` field contains all of the IPVM Tasks set to run in this Workflow, each labelled by a human-readable key.

See the [Task](FIXME) section for more.

## 2.1.9 Exception

The `exception` field contains a Task with predefined inputs. See the [Exception Handling](FIXME) section for more.

## 2.1.10 Signature

The signature of the CID represented by the other fields.

## 2.2 Example

Here is a simple example:

```
┌─────────┐   ┌─────────┐
│         │   │         │
│  left   │   │  right  │
│         │   │         │
└────────┬┘   └─┬───────┘
         │      │
         │      │
       ┌─▼──────▼┐
       │         │
       │   end   │
       │         │
       └─────────┘
```

Here, two tasks (`left` and `right`) are used as input to a third task (`end`). This is fully configured in IPVM as:

``` json
{
  "type": "ipvm/workflow",
  "version": "0.1.0",
  "requestor": "did:key:zAlice",
  "nonce": "o3--8Gdu5",
  "verification": {"optimistic": 2},
  "tasks": {
    "left": {
      "type": "ipvm/wasm",
      "version": "0.1.0",
      "wasm": "bafkreiecadaahndb55cgvemhctwoojcc4hv4alogybpqndzj4mq7brixcy",
      "inputs": [],
      "outputs": ["foo", "bar"] <!-- FIXME component model / wit instead? -->
    },
    "right": {
      "type": "ipvm/wasm",
      "wasm": "bafkreidrvex7kbqiow7gbqzvj452hr3vbifmfvyd55qicfwrw6xvq3qnlq",
      "inputs": [
        { "quux": "bafy123" }
      ]
    },
    "end": {
      "type": "ipvm/wasm",
      "wasm": "bafkreihvr3nup2lpny3ip3hkqv7s7ggq5wit5dkvyaexztnl54rkrlbdhe",
      "inputs": [
        { "a": { "from": "left", "output": "bar" } },
        { "b": { "from": "right" } },
        { "c": 123 }
      ]
    }
  },
  "signature": "abcdef"
}
```

# 3 Global Defaults

The global defaults object contains options for the Workflow itself, as well as cascading defaults for Tasks.

| Field     | Type         | Description                  | Required | Default |
|-----------|--------------|------------------------------|----------|---------|
|           |              |                              |          |         |
| `wasm`    | `CID or URI` | Reference to the Wasm to run | Yes      |         |
| `effects` |              |                              |          |         |
 
## 3.1 Global Wasm Configuration

## 3.2 Global Effects Configuration

# 4 Tasks

While an indivdual invocation is structured like an AST (and eventually memoized as such), the tasks in a workflow spec MAY be unordered. Execution order MUST be determined by the scheduler and implied from the inputs.

For more detail, refer to the [Task](FIXME) spec

## 4.1 Pipelining

The output of one task is often the input to another. This is called pipelining, and MUST form one or more directed acyclic graphs (DAGs). Graphs MAY be unrooted.

For example, this is a legal set of task graphs in a single workflow.

```
┌───────────────Workflow Tasks────────────────┐
│                                             │
│                                             │
│  ┌─────────┐  ┌─────────┐      ┌─────────┐  │
│  │         │  │         │      │         │  │
│  │         │  │         │      │         │  │
│  │         │  │         │      │         │  │
│  └───────┬─┘  └─┬───────┘      └────┬────┘  │
│          │      │                   │       │
│          │      │                   │       │
│        ┌─▼──────▼─┐            ┌────▼────┐  │
│        │          │            │         │  │
│        │          │            │         │  │
│        │          │            │         │  │
│        └─┬──────┬─┘            └─────────┘  │
│          │      │                           │
│          │      │                           │
│  ┌───────▼─┐  ┌─▼───────┐                   │
│  │         │  │         │                   │
│  │         │  │         │                   │
│  │         │  │         │                   │
│  └─────────┘  └─────────┘                   │
│                                             │
│                                             │
└─────────────────────────────────────────────┘
```

Pipelining is acheived via dataflow. Every task is given a name, and its output(s) MUST be referenced by either the task's CID or its name inside the task map. If the task has more than one output, the output MUST be referenced by index (starting from 0) or name.

```
{"from": "previousTask"}
{"from": "previousTask", "out": 3}
{"from": "bafkreifovuswf6ss7czm5gk6ibnd7klhoojhynmiydj6cf7p2yjdsevlga", "out": "firstName" }
```

References by CID MAY be tasks that executed outside of the current workflow. If the task was not yet executed, it MUST NOT run inside this Workflow.


# 7 Exception Handler

Note that while IPVM MUST treat the pure tasks together as transactional, it is not possible to roll back any destructive effects that have been run. As such, it is RECOMMENDED to have few (if any) tasks depend on the output of a destructive effect.

It is often desirable to fire a specific workflow in the case that a workflow fails. Such cases MAY include wall-clock timeouts, running out of gas, loss of network access, or ___, among others. The exception handler fills a similar role to [GenServer.handle_info/2](https://hexdocs.pm/elixir/1.14.2/GenServer.html#c:handle_info/2).

Each task MAY include a failure workflow to run on failure.

Note that effectful exception handlers that emit effects (such as network access) MAY fail for the same reason as the workflow that caused the exception to be thrown. Running a pure value is RECOMMENDED.

# 8 Related Work and Prior Art

AWS Lambda workflow specs
OCI
E Language
CapNet
Project Naiad
Bloom
PACT/HydroLogic
BucketVM
Bacalhau
AquaVM

It is not possible to mention the separation of effects from computation without mentioning the algebraic effect lineage from Haskell, OCaml, and Eff. While the overall system looks quite different from the their type-level effects, this work owes a debt to at least Gordon Plotkin and John Power's work on [computational effects](https://homepages.inf.ed.ac.uk/gdp/publications/Overview.pdf), 

# 9 Acknowledgments

* Steb
* Mel
* Christine
* Blaine Cook
* Luke Marsden
* Quinn Wilton
