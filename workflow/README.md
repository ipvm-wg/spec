# IPVM Workflow Specification v0.1.0

> In late 1970 or early ’71 I approached IBM Canada’s Intellectual Property department to see if we could take out a patent on the basic idea [of dataflow]. Their recommendation, which I feel was prescient, was that this concept seemed to them more like a law of nature, which is not patentable. 
>
> J. Paul Morrison, [Flow-Based Programming](https://jpaulm.github.io/fbp/book.html)

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
* [Simon Worthington](https://github.com/simonwo), [Bacalhau Project](https://www.bacalhau.org/)

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

## Dependencies

* [DAG-CBOR](https://ipld.io/specs/codecs/dag-cbor/spec/)
* [UCAN Invocation](https://github.com/ucan-wg/invocation/)
* [VarSig](https://github.com/ChainAgnostic/varsig/)

# 0 Abstract

An IPVM Workflow defines everything required to execute one or more tasks: global configuration for a proposed workflow, their individual tasks, dependencies between tasks, authorization, metadata, signatures, and so on.

# 1 Introduction

The potential complexity of a fully distributed execution by potentially unknown peers is very high. IPVM Workflows reduce the number of possible states by forcing explicit handling of any dangerous effects. The IPVM Workflow spec is a declarative document that MAY be inspected, transmitted, logged, and negotiated. Unlike a system like WASI, there is a strict separation of effects from pure data, with no intermixing of computation with live pipes.

While capability sytems such as [UCAN](https://github.com/ucan-wg/spec/) include the information required to execute a workflow, they assume an established audience (which too rigid for negotiation), do not signal the _intent_ to execute, and do not include fields to configure settings for the actual runtime.

IPVM Workflows MUST be suitable for the proposal of workflows and negotiation with provuders on a discovery layer (ahead of credential delegation), execution on untrusted peer machines, and ___. Workflows SHOULD provide a sufficiently expressive base to build more complex models such as actors, event-driven systems, map-reduce, and so on.

## 1.1 Design Philosophy

> 8. A programming language is low level when its programs require attention to the irrelevant.
>
> — Alan Perlis, Epigrams on Programming 

While IPVM in aggregate is capable of executing arbitrary programs, individual IPVM Workflows are specified declaratively, and tasks workflows MUST be acyclic. Invocation in the decalarative style liberates the programmer from worrying about explicit sequencing, parallelism, memoization, distribution, and nontermination in a trustless settings. Such constraints also grants the runtime control and flexibility to schedule tasks in an efficient and safe manner.

These constraints impose specific practices. There is no first-class concept of persistent objects or loops. Loops, actors, vats, concurrent objects, and so on MAY be implemented on top of IPVM Workflows by enqueuing new workflows with the effect system (much like a [mailbox receive loop](https://www.erlang.org/doc/efficiency_guide/processes.html)).

The core restrictions enforced by the design of IPVM Workflows are:

1. Execution MUST terminate in finite time
2. Workflow tasks MUST form a partial order
3. Effects MUST be decalared ahead of time and managed by the IPVM host

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

| Field           | Type                                               | Description                                  | Required | Default |
|-----------------|----------------------------------------------------|----------------------------------------------|----------|---------|
| `ipvm/workflow` | `Workflow`                                         | IPVM Workflow                                | Yes      |         |
| `signature`     | [Varsig](https://github.com/ChainAgnostic/varsig/) | Varsig (IPLD signature) of serialized fields | Yes      |         |

| Field       | Type                        | Description                                      | Required | Default |
|-------------|-----------------------------|--------------------------------------------------|----------|---------|
| `v`         | `"0.1.0"`                   | IPVM workflow version                            | Yes      |         |
| `nnc`       | `String`                    | Unique nonce                                     | Yes      |         |
| `meta`      | `{String : Any}`            | User-defined object (tags, comments, etc)        | No       | `{}`    |
| `par`       | `CID-relative Path or null` | The CID of the initiating (parent) task (if any) | No       | `null`  |
| `defaults`  | `IpvmConfig`                |                                                  | No       | `{}`    |
| `tasks`     | `UCAN.Invocation`           | UCAN Invocation                                  | Yes      |         |
| `exception` | `Task.DeterminisicWasm`     |                                                  | No       | `null`  |

``` ipldsch
type SignedWorkflow {
  inv UCAN.Invocation
  
}
```

``` json
{
  "ucan/invoke": {
    "v": "0.1.0",
    "nnc": "02468",
    "ext": {
      "ipvm/config": {
     
      }
    },
    "prf": [
      {"/": "bafkreie2cyfsaqv5jjy2gadr7mmupmearkvcg7llybfdd7b6fvzzmhazuy"},
      {"/": "bafkreibbz5pksvfjyima4x4mduqpmvql2l4gh5afaj4ktmw6rwompxynx4"}
    ],
    "run": {
      "notify-bob": {
        "with": "mailto://alice@example.com",
        "do": "msg/send",
        "inputs": [
          {
            "to": "bob@example.com",
            "subject": "DNSLink for example.com",
            "body": "Hello Bob!"
          }
        ],
        "ipvm/config": {
          "time": {"seconds": "100"}
        }
      },
      "log-as-done": {
        "with": "https://example.com/report"
        "do": "crud/update"
        "inputs": {
          "from": "mailto://alice@exmaple.com",
          "to": ["bob@exmaple.com"],
          "event": "email-notification",
          "value": {"ucan/promise": ["/", "notify-bob"]} // Pipelined promise
        }
      }
    }
  },
  "sig": {"/": {"bytes:": "5vNn4--uTeGk_vayyPuNTYJ71Yr2nWkc6AkTv1QPWSgetpsu8SHegWoDakPVTdxkWb6nhVKAz6JdpgnjABppC7"}}
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

Note that while IPVM MUST treat the pure tasks together as transactional, it is not possible to roll back any destructive effects that have been run. As such, it is RECOMMENDED to have few (if any) tasks depend on the output of a destructive effect.

It is often desirable to fire a specific workflow in the case that a workflow fails. Such cases MAY include wall-clock timeouts, running out of gas, loss of network access, or ___, among others. The exception handler fills a similar role to [GenServer.handle_info/2](https://hexdocs.pm/elixir/1.14.2/GenServer.html#c:handle_info/2).

Each task MAY include a failure workflow to run on failure.

Note that effectful exception handlers that emit effects (such as network access) MAY fail for the same reason as the workflow that caused the exception to be thrown. Running a pure value is RECOMMENDED.


## 2.1.10 Signature

The signature of the CID represented by the other fields.

## 2.2 IPLD Schema

``` ipldsch
type SignedWorkflow struct {
  wfl Workflow
  sig VarSig
}

type Workflow struct {
  v          SemVer
  meta       {String : Any}          (implicit {})
  parent     nullable &Task          (implicit Null)
  defauts    SystemConfig            (implicit {})
  tasks      UCAN.Invocation
  exception  &Task.DeterministicWasm (implicit Null)
}
```

## 2.3 JSON Exmaples

``` json
{
  "ipvm/workflow": {
    "v": "0.1.0",
    "nnc": "9dn-3*",
    
  }
  // MORE HERE
  "signature": "abcdef"
}
```

# 3 System Configuation

The global defaults object contains options for the Workflow itself, as well as cascading defaults for Tasks.

| Field    | Type              | Description                             | Required | Default                  |
|----------|-------------------|-----------------------------------------|----------|--------------------------|
| `secret` | `Boolean or null` | Whether the output is unsafe to publish | No       | `null`                   |
| `check`  | `Verification`    | How to verify the output                | No       | `"attestation"`          |
| `time`   | `TimeLength`      | Timeout                                 | No       | `[5, "minutes"]`         |
| `memory` | `InfoSize`        | Memory limit                            | No       | `[100, "kilo", "bytes"]` |
| `disk`   | `InfoSize`        | Disk limit                              | No       | `[10, "mega", "bytes"]`  |

## 3.1 Fields

### 3.1.1 Version

The version of the IPVM 

### 3.1.2 Secret Flag

The `secret` flag marks a task as being unsuitable for publication.

If the `sceret` field is explicitely set, the task MUST be treated per that setting. If not set, the `secret` field defaults to `null`, which behaves as a soft `false`. If such a task consumes input from a `secret` source, it is also marked as `secret`.

Note: there is no way to enforce secrecy at the task-level, so such tasks SHOULD only be negotiated with runners that are trusted. If secrecy must be inviolable, consider with [multi-party computation (MPC)](https://en.wikipedia.org/wiki/Secure_multi-party_computation) or [fully homomorphic encryption (FHE)](https://en.wikipedia.org/wiki/Homomorphic_encryption#Fully_homomorphic_encryption) inside the task.



FIXME

## 3.2 IPLD Schema

``` ipldsch
type SystemConfig struct {
  secret Boolean      (implicit False)
  check  Verification (implicit Attestation)
  time   Integer 
  memory Integer
  disk   Integer
}

type Verification union {
  | Oracle
  | Consensus
  | Optimistic
  | ZKP
} representation keyed

type Oracle union {
  | Attestation "attestation"
  | ThirdParty(DID)
}

type Optimistic struct {
  confirmations Integer
  referee Referee
}

type Referee enum {
  | ZK(ZeroKnowledge)
  | Trusted(DID)
}

type Consensus struct {
  agents [DID]
}

type ZKP enum {
  | Groth16
  | Nova
  | Nova2
}
```

# 4 Tasks

While an indivdual invocation is structured like an AST (and eventually memoized as such), the tasks in a workflow spec MAY be unordered. Execution order MUST be determined by the scheduler and implied from the inputs.

For more detail, refer to the [Task](FIXME) spec

Task Canonicalization -- FIXME ref the UCAN Invocation spec



# Tasks

> With hands of iron, there's not a task we couldn't do
>
> — [The Protomen](https://en.wikipedia.org/wiki/The_Protomen), The Good Doctor

Tasks are the smallest unit of negotiated work in an IPVM workflow. Each Task is restricted to a single type, such as a Wasm module, or effects like an HTTP `GET` request.

Tasks describe everything required to the negotate the of work. While all Tasks share some things in common, the details MAY be quite different.



TODO
  - deal version: prf: []
  - actionable version prf: [ucans]

# 1.1 Task Envelope

IPVM Tasks are defined as an extension of [UCAN Actions](https://github.com/ucan-wg/invocation/blob/rough/README.md#32-ipld-schema). Task types MAY require specific fields in the `inputs` field.  Timeouts, gas, credits, transactional guarantees, result visibility, and so on MAY be separately confifured in the `ipvm/config` field.

An IPVM Task MUST be embedded inside of a [UCAN Action](https://github.com/ucan-wg/invocation)'s `inputs` field. As such, the URI and command to be run are handled at the Action layer. 


``` ipldsch
type Action struct {
  with      URI
  do         Ability
  input      Any
  taskConfig TaskConfig (implicit {})
}
```

A Task is a subtype of a UCAN Action

All tasks MUST contain at least the following fields. They MAY contain others, depending on their type.



## 2.3 JSON Examples

``` json
{
  "with": "dns://example.com?TYPE=TXT",
  "do": "crud/update",
  "inputs": { 
    "value": "hello world"
  },
  "meta": {
    "ipvm/config": {
      "v": "0.1.0",
      "secret": false,
      "timeout": { "ms": 5000 },
      "retries": 5,
      "verification": "attestation"
    }
  }
}
```

Deterministic WebAssembly

``` js
{
  // Clean, but possible a bridge too far. Probably handle this in an implcit like CIDs
  "supply-gas": {
    "with": "gas:reserve://mine", // Or something... needs work at least
    "do": "gas/supply",
    "inputs": {
      "on": ["/", "some-wasm"],
      "max": 1000
    }
  },
  "some-wasm": {
    "with": "wasm:1:Qm12345", // Or something... wasm:Qm12345?
    "do": "ipvm/run",
    "inputs": {
      "func": "calculate",
      "args": [
        1,
        "hello world",
        {"c": {"ucan/promise": ["/", "some-other-action"]}},
        {"a": 1, "b": 2, "c": 3}
      ]
    },
    "ipvm/config": {
      "v": "0.1.0",
      "secret": false,
      "check": {"optimistic": 2}
    }
  }
}
```

Docker

``` json
{
  "with": "docker:1:Qm12345", // Or something... wasm:Qm12345?
  "do": "docker/run",
  "inputs": {
    "func": "calculate",
    "args": [
      1,
      "hello world",
      {"c": {"ucan/promise": ["/", "some-other-action"]}},
      {"a": 1, "b": 2, "c": 3}
    ],
    "container": {
      "entry": "/",
      "workdir": "/",
    },
    "env": {
      "$FOO": "bar"
    }
  },
  "ipvm/config": {
    "v": "0.1.0",
    "secret": false,
    "check": {"optimistic": 2}
  }
}
```

# 5 Appendix

## 5.1 Support Types

``` ipldsch
type TimeUnit enum {
  | Seconds 
  | Minutes 
  | Days
  | Weeks
  | Years
}

type InfoUnit enum {
  | Bits 
  | Nibble
  | Bytes
  | Word32
  | Word64
} 

type Unit union {
  | TimeUnit
  | InfoUnit
}

type SIPrefix enum {
  | Pico "p"
  | Nano "n"
  | Micro "u"
  | Milli "m"
  | Centi "c"
  | Deci "d"
  | Unity
  | Deca "da"
  | Hecto "ha"
  | Kilo "k"
  | Mega "M"
  | Giga "G"
  | Tera "T"
  | Peta "P"
  | Exa  "E"
}

type TimeLength struct {
  magnitude integer
  prefix    Prefix (implicit Unity)
  unit      TimeUnit
} representation tuple

type InfoSize struct {
  magnitude integer
  prefix    Prefix (implicit Unity)
  unit      InfoUnit
} representation tuple

type Measure union {
  | TimeLength
  | InfoSize
}

[400, "nano", "seconds"]
```



# 5 Related Work and Prior Art

* [Bacalhau Job (Alpha)](https://github.com/filecoin-project/bacalhau/blob/8568239299b5881bc90e3d6be2c9aa06c0cb3936/pkg/model/job.go#L113-L126)
* [BucketVM](https://purrfect-tracker-45c.notion.site/bucket-vm-73c610906fe44ded8117fd81913c7773)
* [WarpForge Formulas](https://github.com/warptools/warpforge/blob/master/examples/100-formula-parse/example-formulas.md)

AWS Lambda workflows
GH Workflows
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

# 6 Acknowledgments

* Steb
* Mel
* Christine
* Blaine Cook
* Luke Marsden
* Quinn Wilton
