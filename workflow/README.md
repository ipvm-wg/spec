# IPVM Workflow Specification v0.1.0

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

An IPVM Workflow is a declarative cofiguration. A Workflow provides everything required to execute one or more tasks: defaults, tasks and their dependencies, authorization, metadata, signatures, and so on.

# 1 Introduction

> In late 1970 or early ’71 I approached IBM Canada’s Intellectual Property department to see if we could take out a patent on the basic idea [of dataflow]. Their recommendation, which I feel was prescient, was that this concept seemed to them more like a law of nature, which is not patentable. 
>
> J. Paul Morrison, [Flow-Based Programming](https://jpaulm.github.io/fbp/book.html)

The potential complexity of a fully distributed execution by untrusted peers is very high. IPVM Workflows reduce the number of possible states by forcing explicit handling of any dangerous effects. The IPVM Workflow spec is a declarative document that MAY be inspected, transmitted, logged, and negotiated. Unlike s systems like WASI, there is a strict separation of effects from pure data, an emphasis on verifiability, and [promise pipelining](http://erights.org/elib/distrib/pipeline.html).

IPVM Workflows MUST be suitable for the proposal of workflows and negotiation with providers on a discovery layer (ahead of credential delegation), execution on untrusted peer machines, and verification. Workflows SHOULD provide a sufficiently expressive base to build more complex models such as actors, event-driven systems, map-reduce, and so on.

## 1.1 Design Philosophy

While IPVM in aggregate is capable of executing arbitrary programs, individual IPVM Workflows are specified declaratively, and tasks workflows MUST be acyclic. Invocation in the declarative style liberates the programmer from worrying about explicit sequencing, parallelism, memoization, distribution, and nontermination in a trustless settings. Such constraints also grants the runtime control and flexibility to schedule tasks in an efficient and safe manner.

These constraints impose specific practices. There is no first-class concept of persistent objects or loops. Loops, actors, vats, concurrent objects, and so on MAY be implemented on top of IPVM Workflows by enqueuing new workflows with the effect system (much like a [mailbox receive loop](https://www.erlang.org/doc/efficiency_guide/processes.html)).

# 2 Envelope

The outer wrapper of a workflow MUST contain the following fields:

| Field           | Type       | Description                                                             | Required |
|-----------------|------------|-------------------------------------------------------------------------|----------|
| `ipvm/workflow` | `Workflow` | IPVM Workflow                                                           | Yes      |
| `signature`     | `VarSig`   | [VarSig](https://github.com/ChainAgnostic/varsig/) of serialized fields | Yes      |

| Field      | Type                | Description                                                                         | Required | Default |
|------------|---------------------|-------------------------------------------------------------------------------------|----------|---------|
| `v`        | `"0.1.0"`           | IPVM workflow version                                                               | Yes      |         |
| `meta`     | `{String : Any}`    | User-defined object (tags, comments, etc)                                           | No       | `{}`    |
| `parent`   | `&Workflow or Null` | The CID of the initiating workflow (if any) FIXME probably want the task & workflow | No       | `Null`  |
| `config`   | `Config`            |                                                                                     | No       | `{}`    |
| `defaults` | `Config`            |                                                                                     | No       | `{}`    |
| `tasks`    | `UCAN.Invocation`   | UCAN Invocation                                                                     | Yes      |         |
| `on`       | `Listeners`         | IPVM event listeners                                                                | No       | `{}`    |

## 2.1 Fields

## 2.1.1 Version

The `v` field MUST contain the IPVM Workflow version.

## 2.1.2 Metadata

The OPTIONAL `meta` field contains a user-definable JSON object. This is useful for including things like tags, comments, and so on.

## 2.1.3 Parent

The OPTIONAL `parent` field contains the CID of the IPVM Task that initiated it (if any).

## 2.1.4 Config

The OPTIONAL global `config` object (FIXME section X.Y) sets the configuration for the workflow itself, and defaults for tasks.

## 2.1.5 Defaults

The OPTIONAL `defaults` field configures default [configs](#3-configuration) for tasks.
 
## 2.1.6 Tasks

The `tasks` field contains all of the IPVM [Tasks](#4-task-configuration) set to run in this Workflow, each labelled by a human-readable key.

## 2.1.7 Exception Handler

The OPTIONAL `catch` field contains a Task with predefined inputs. See the [Exception Handling](#7-exception-handling) section for more deatil.

## 2.2 IPLD Schema

``` ipldsch
type SignedWorkflow struct {
  work Workflow (rename "ipvm/workflow")
  sig  VarSig
}

type Workflow struct {
  v       SemVer
  meta    {String : Any}  (implicit {})
  parent  nullable &Task  (implicit Null)
  global  Config          (implicit {}) 
  defauts Config          (implicit {})
  tasks   UCAN.Invocation
  catch   nullable &Wasm  (implicit Null)
}
```

## 2.3 JSON Exmaples

``` json
{
  "ipvm/workflow": {
    "v": "0.1.0",
    "meta": {
      "tags": ["fission", "bacalhau", "dag-house"]
    },
    "global": {
      "time": [10, "minutes"],
    },
    "defaults": {
      "gas": 1000,
      "memory": [10, "mega", "bytes"]
    },
    "catch": "bafkreifsaaztjgknuha7tju6sugvrlbiwbyx5jf2pky2yxx5ifrpjscyhe",
    "tasks": "ucan/invoke": {
      "v": "0.1.0",
      "nnc": "02468",
      "prf": [ // FIXME having to resend this is a pain!
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
          "meta": {
            "ipvm/config": {
              "time": {"minutes": "30"},
              "secret": true
            }
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
    }
  },
  "sig": {"/": {"bytes:": "5vNn4--uTeGk_vayyPuNTYJ71Yr2nWkc6AkTv1QPWSgetpsu8SHegWoDakPVTdxkWb6nhVKAz6JdpgnjABppC7"}}
}
```

# 3 Configuation

The IPVM configuration struct defines secrecy, quotas, and verification strategy:

| Field    | Type              | Description                             | Required | Default                  |
|----------|-------------------|-----------------------------------------|----------|--------------------------|
| `secret` | `Boolean or null` | Whether the output is unsafe to publish | No       | `null`                   |
| `check`  | `Verification`    | [Verification strategy](FIXME)          | No       | `"attestation"`          |
| `time`   | `TimeInterval`    | Timeout                                 | No       | `[5, "minutes"]`         |
| `memory` | `InfoSize`        | Memory limit                            | No       | `[100, "kilo", "bytes"]` |
| `disk`   | `InfoSize`        | Disk limit                              | No       | `[10, "mega", "bytes"]`  |
| `gas`    | `Integer`         | Gas limit                               | No       | `1000`                   |

This MAY be set globally or configured on [individual Tasks](#4-task-configuration).

## 3.1 Fields

### 3.1.1 Secret Flag

The `secret` flag marks a task as being unsuitable for publication.

If the `sceret` field is explicitely set, the task MUST be treated per that setting. If not set, the `secret` field defaults to `null`, which behaves as a soft `false`. If such a task consumes input from a `secret` source, it is also marked as `secret`.

Note: there is no way to enforce secrecy at the task-level, so such tasks SHOULD only be negotiated with runners that are trusted. If secrecy must be inviolable, consider with [multi-party computation (MPC)](https://en.wikipedia.org/wiki/Secure_multi-party_computation) or [fully homomorphic encryption (FHE)](https://en.wikipedia.org/wiki/Homomorphic_encryption#Fully_homomorphic_encryption) inside the task.

### 3.1.2 Verification Strategy

The OPTIONAL `check` field MUST supply a verification strategy if present. If omitted, it MUST default to `"attestation"`.

### 3.1.4 Time Quota

The OPTIONAL `time` field configures the upper limit in wall-clock time that the executor SHOULD allow.

### 3.1.5 Memory Quota

The OPTIONAL `memory` field configures the upper limit in system memory that the executor SHOULD allow.

### 3.1.6 Disk Quota

The OPTIONAL `disk` field configures the upper limit in system memory that the executor SHOULD allow.

### 3.1.7 Gas Quota

The OPTIONAL `disk` field configures the upper limit in Wasm gas that the executor SHOULD allow.

## 3.2 IPLD Schema

``` ipldsch
type SystemConfig struct {
  secret Boolean      (implicit False)
  check  Verification (implicit Attestation)
  gas    Integer      (implicit 0)
  time   optional TimeInterval
  memory optional InfoSize
  disk   optional InfoSize
}
```

## 3.3 JSON Examples

``` json
{
  "secret": true,
  "check": {"optimistic": {"confirmations": 2, "referee": "did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4"}},
  "gas": 5000,
  "time": [45, "minutes"],
  "memory": [500, "kilo", "bytes"],
  "disk": [20, "mega", "bytes"]
}
```

# 4 Task Configuration

> With hands of iron, there's not a task we couldn't do
>
> — [The Protomen](https://en.wikipedia.org/wiki/The_Protomen), The Good Doctor

Tasks are the smallest level of work granularity a workflow. Tasks describe everything required to the negotate and execute all of the of work. IPVM Tasks are defined as a subtype of [UCAN Tasks](https://github.com/ucan-wg/invocation/blob/main/README.md#32-ipld-schema). Task types MAY require specific fields in the `inputs` field.  Timeouts, gas, credits, transactional guarantees, result visibility, and so on MAY be separately confifured in the `ipvm/config` field.

Tasks MAY be configured in aggragate in the [global defaults](#215-defaults). Individual Task configuration MUST be embedded inside of a [UCAN Action](https://github.com/ucan-wg/invocation)'s `meta['ipvm/confg']` field.

Note that while all Tasks have a resource (URI) and action, the details MAY be quite different. Each Task is restricted to a specific [safety level](FIXME) based on its resource/action pair (such as a deterministic Wasm module or [effects](FIXME) like an HTTP `GET` request). Tasks MUST be scheduled according to its safety properties, which MAY have a performance impact.

## 4.1 Fields

Recall UCAN Invocation Tasks:

| Field    | Type             | Description                                    | Required | Default |
|----------|------------------|------------------------------------------------|----------|---------|
| `with`   | `URI`            |                                                | Yes      |         |
| `do`     | `Ability`        |                                                | Yes      |         |
| `inputs` | `Any`            |                                                | Yes      |         |
| `meta`   | `{String : Any}` | Fields that will be ignored during memoization | No       | `{}`    |

An OPTIONAL IPVM `Config` MAY be included at the `meta['ipvm/config']` path. The `meta` field SHOULD not captured as part of task memoization, so this informtaion will be omitted from the distributed invocation table. If included, the `Config` MUST set the IPVM configuration for this Task, overwriting any of the fields on the envelope's top-level `defaults` field, or system-wide defaults.

## 4.3 JSON Examples

``` json
{
  "simple": {
    "with": "dns://example.com?TYPE=TXT",
    "do": "crud/update",
    "inputs": { 
      "value": "hello world"
    },
    "meta": {
      "ipvm/config": {
        "secret": false
        "timeout": [500, "milli", "seconds"],
        "verification": "attestation"
      }
    }
  }
}
```

``` js
{
  "supply-gas": {
    "with": "gas:reserve://mine", // Or something... needs work at least FIXME
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
      "check": {
        "optimistic": 17, 
        "referee": "did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4"
      }
    }
  }
}
```

``` json
{
  "with": "ipfs://bafkreidvq3uqoxcxr44q5qhgdk5zk6jvziipyxguirqa6tkh5z5wtpesva",
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
  "meta": {
    "ipvm/config": {
      "v": "0.1.0",
      "secret": false,
      "check": {
        "optimistic": 2, 
        "referee": "did:key:zStEZpzSMtTt9k2vszgvCwF4fLQQSyA15W5AQ4z3AR6Bx4eFJ5crJFbuGxKmbma4"
      }
    }
  }
}
```

# 5 Exception Handler

If present, the OPTIONAL `catch` field MUST be run in response to a `Task` returning on the `Failure` branch. The determinitsic & pure Wasm module MUST take a `Failure` object as input, and MUST return data in the following shape:

``` ipldsch
type Handle union {
  | String "rewire" -- Task name inside the current Workflow
  | String "msg"    -- Format the error message and panic
}
```

If the `msg` branch is returned, the invocation MUST immedietly rethrow with the update message.

Note that while IPVM MUST treat the pure tasks together as transactional. It is not possible to roll back any destructive effects that have already been run. As such, it is RECOMMENDED to have few (if any) tasks depend on the output of a destructive effect, so they can be scheduled at the end of the workflow.

# 6 Receipt Output

| Field  | Type            | Description                                                           | Required | Default |
|--------|-----------------|-----------------------------------------------------------------------|----------|---------|
| `inv`  | `&Invocation`   | CID of the Invocation that generated this response                    | Yes      |         |
| `out`  | `{String: Any}` | The results of each call, the task's label. MAY contain sub-receipts. | Yes      |         |
| `meta` | `Any`           | Non-normative extended fields                                         | No       | `null`  |

If the `catch` field is set on the outer `Workflow`, The `out` field MAY include the output under the `ipvm/catch` key

# 7 Appendix

## 7.1 Support Types

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
} 

type Unit union {
  | TimeUnit
  | InfoUnit
}

type SubPrefix enum {
  | Pico "p"
  | Nano "n"
  | Micro "u"
  | Milli "m"
  | Centi "c"
  | Deci "d"
}

type SuperPrefix enum {
  | Deca "da"
  | Hecto "ha"
  | Kilo "k"
  | Mega "M"
  | Giga "G"
  | Tera "T"
  | Peta "P"
  | Exa  "E"
}

type SIPrefix union {
  | SubPrefix
  | SuperPrefix
}

type TimeInterval struct {
  magnitude Integer
  prefix    optional SIPrefix
  unit      TimeUnit
} representation tuple

type InfoSize struct {
  magnitude Integer
  prefix    optional SubPrefix
  unit      InfoUnit
} representation tuple

type Measure union {
  | TimeInterval
  | InfoSize
}
```

## 7.1.1 JSON Examples

``` json
[400, "nano", "seconds"]
[5, "seconds"]
[378, "exa", "bytes"]
```

# 8 Related Work and Prior Art

The [Bacalhau Job (Alpha)](https://github.com/filecoin-project/bacalhau/blob/8568239299b5881bc90e3d6be2c9aa06c0cb3936/pkg/model/job.go#L113-L126) spec is a complete runner spec for Docker, Wasm, and Python source. At time of writing, it runs on a volunteer network, and has plans to integrate an authority layer.

BucketVM and [`w3-machines`](https://github.com/web3-storage) are two approaches from [DAG House](https://dag.house) to extend UCAN to invocations and workflows. At time of writing, both approaches are focused on invocation inside a cloud microservice deployment. Configuration is not required, as jobs are not negotiated.

[Cloud Native Builpacks](https://buildpacks.io/) are descriptions of an environment that stack together. They output an [OCI](https://opencontainers.org/) container.

[GitHub Workflows](https://docs.github.com/en/actions/using-workflows) is a configuration to run one or more jobs, hooked into events on their platform. Workflows can be composed out of discrete actions or from other workflows.

[Lambda Workflows](https://docs.aws.amazon.com/amazonswf/latest/developerguide/swf-dg-create-workflow.html) are a serverless workflow layer built on top of AWS, and thus integrates with their other offerings like IAM, S3, payments, and so on.

[Project Naiad](https://www.microsoft.com/en-us/research/video/introducing-project-naiad-and-differential-dataflow/) and its lineage (e.g. [Timely Dataflow](https://timelydataflow.github.io/timely-dataflow/), [Differential Dataflow](https://timelydataflow.github.io/differential-dataflow/)) offer an extremely powerful dataflow model, including differential updates, control flow cycles, long running processes, but in a trusted environment. Such features could be supported for a subset of task types in IPVM in the future.

[WarpForge Formulas](https://github.com/warptools/warpforge/blob/master/examples/100-formula-parse/example-formulas.md) describe how to reproducably build and cache packages. The functionality is a specialization of IPVM workflows, and may be configurable with IPVM in the future.

# 9 Acknowledgments

[Luke Marsden](https://github.com/lukemarsden) for a long fateful discussion while [stuck on a tarmac](https://www.theguardian.com/world/2022/nov/04/spanish-airspace-partially-closed-as-chinese-rocket-debris-falls-to-earth) about how to make IPVM and Bacalhau work more closely together.

Thanks to [James Walker](https://github.com/walkah) for helping draw parallels between CIDs, IPLD, and raw bytes for promises in support of complex data pipelines.

Many thanks to [Quinn Wilton](https://github.com/QuinnWilton) for her review of the spec, suggesting terms that would be most familiar to developers, talking through how to make the exception handling useful-but-safe in a static workflow, and suggesting further work involving fixed point computation.

Many thanks to [Irakli Gozalishvili](https://github.com/Gozala) for the long discussions about invocation needs at [DAG House](https://dag.house), keeping the conversation grounded in a capabilities worldview, and for the many, many comments on various iterations of this spec across two repos.

Thanks to [Blaine Cook](https://github.com/blaine) for several conversations about developer expectations and effect systems.
