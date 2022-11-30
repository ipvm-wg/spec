# Interplanetary Virtual Machine (IPVM) Spec v0.1.0

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Blaine Cook](https://github.com/blaine), [Fission](https://fission.codes)
* [Zeeshan Lakhani](https://github.com/zeeshanlakhani), [Fission](https://fission.codes)
* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
    
## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

## Depends On 

* [Multiformats](https://multiformats.io)
* [UCAN Capabilities](https://github.com/ucan-wg/spec)
* [UCAN Invocation](https://github.com/ucan-wg/invocation)

## Subspecs 

* Description Formats
  * [Workflow](./workflow/README.md)
  * [Task](./task/README.md)
  * [Effect](./effect/README.md)
  * [UCAN Invocation](https://github.com/ucan-wg/invocation)
* Runtime
  * Distributed Scheduler
    * Planner
  * Execution
* Lifecycle
  * Request
  * Negotiation
  * Capabilty
    * SPKI
    * OCapN
  * Verification
  * Payment Channel
* Wasm μKernel
  * IPFS
  * Atomics and STM
  * Actor
* First-Class Effects
  * Randomness
  * HTTP
  * FVM
  * Bacalhau

# 0 Abstract

IPVM

An IPVM "job" is a declarative description of WebAssembly and managed effects to be run by the IPVM runtime.

# 1 Motivation

IPVM provides a deterministic-by-default, content addressed execution environment. Execution may always be run locally, but there are many cases where remote exection is desirable: access to large data, faster processors, trusted execution environments, or access to specialized hardware, among others.

> Because he was talking (mainly) to a set of platform folks he admonished us to think about how we can build platforms that lead developers to write great, high performance code such that developers just fall into doing the “right thing”. Rico called this the Pit of Success.
>
>  — Brad Abrams, [The Pit of Success](https://learn.microsoft.com/en-us/archive/blogs/brada/the-pit-of-success)

## 1.1 Minimizing Complexity

> Every application has an inherent amount of irreducible complexity. The only question is: Who will have to deal with it — the user, the application developer, or the platform developer?
> -- [Tesler's Law](https://en.wikipedia.org/wiki/Law_of_conservation_of_complexity)

With "jobs" as the unit of execution, programmers gain flexible cache granularity, parallelism, and ___.

Configuration DSLs like IPVM jobs can become very complex. By their nature, jobs specs are responsible for describing as many 

By having to account for a huge number of possible cases, the burden is placed on the programmer in exchange for a high degree of control. Sensible defaults, [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration), and scoped settingshelp aleviate this problem.

Partial failure in a deterministic system is simplified by using transactional semantics for the job as a whole. The difficult case lies with any effects that destructively update the real world.

# Stack Diagrram

```
┌───────────────────────────────────────────────┬───────────────────────────┐
│                                               │                           │
│             Human Configuration:              │                           │
│  Defaults, Exception Handling, Comments, Tags │                           │
│               (IPVM Workflow)                 │                           │
│                                               │  Multi-Request Pipelining │
├───────────────────────────────────────────────┤     (UCAN Invocation)     │
│                                               │                           │
│      IPVM Config, Verification Level, etc     │                           │
│                 (IPVM Task)                   │                           │
│                                               │                           │
├───────────────────────────────────────────────┴───────────────────────────┤
│                                                                           │
│                               Call Graph                                  │
│                            (UCAN Invocation)                              │
│                                                                           │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│                                Authority                                  │
│                               (UCAN Core)                                 │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

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

# 2 Effect System

The core restrictions enforced by the design of IPVM Workflows are:

1. Execution MUST terminate in finite time
2. Workflow tasks MUST form a partial order
3. Effects MUST be decalared ahead of time and controlled by the IPVM host

While effects MUST be declared up front, they MAY also be emitted as output from pure computation (see the core spec for more). This provides a "legal" escape hatch for building higher-level abstraction that incorporate effects.


## 2.1 Pure Functions

## 2.2 Nondestructive Effects

## 2.3 Destructive Effects

# 3 Job Anatomy

An IPVM job MUST be composed of the following parts:

* Header
* Jobs
* Signature

## 3.1 Header

## 3.2 Jobs

The `jobs` field MUST describe a series of jobs that are expected to run in the session. Jobs MUST be one of the following:

1. A pure computation described by pure (content-addressed) inputs to a Wasm binary
2. A named effect with pure (content-addressed) inputs to be executed by the runtime
3. One of the above, with an input that is the result of a previous step 


### 3.2.1 Web Assembly Job

``` json
{
  "type": "wasm/1.0",
  "with": "bafkreie53mk3duiynh5pzmhuzadaif6hpizod5wr6dt34canmxo7j7jfcu",
  "input": [
      { "firstName": "Boris" },
      { "lastName": "Mann" }
  ],
  "maxGas": 4600,
  "on": {
      "error": [],
      "success": []
  }
}
```

### 3.2.2 Effect Job

### 3.2.3 Pipelining

Each job MUST be labelled with a string. This label MUST be treated as local to the enclosing workflow. Jobs MAY reference each other's output by label in the `from` field. In the case of multiple return values, the index of the output may be further selected with the `out` field. For exammple:

```json
{
  "fullName": {
    "type": "wasm/1.0",
    "with": "bafkreie53mk3duiynh5pzmhuzadaif6hpizod5wr6dt34canmxo7j7jfcu",
    "input": [
        { "firstName": "Boris" },
        { "lastName": "Mann" }
    ]
  },
  "count": {
    "type": "wasm/1.0",
    "with": "bafkreiegbnixdoqsohfz5oninnhpcpwsf7rg6ewnx2lvhp7p5axejrph64",
    "input": [
        { "name": {"from": "fullName", "out": 0 } }
    ]
  }
}
```

The above is roughly equivalent to the (local) function call:

```js
fullName({firstName: "Boris", lastName: "Mann"})[0].count()
```

<!-- FIXME check if Wasm Components / WIT solve for named outputs -->

All resulting graphs MUST be acyclic. The parser MUST check for any cycles and fail immeditely.








* Automatic (and deterministic) parallelism
* Dataflow / job graph
* Effects System
* Partial Failure & Transactionality 
* Auth: SPKI & object capabilities

* Wasm execution in depth
* Spec format IPLD
  * Input addressing

## 2.2 Implicit Parallelism

IPVM does not allow programmer control over parallelism. The resources available to the scheulder MAY be very different from run to run.

The concurrency plan MUST be derived from the dataflow dependencies.


# 3 Higher Abstractions

At the lowest level, IPVM jobs only describe the loading of immutible data.

* Actors
* Vats
* Map/reduce

``` ipldsch
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


# 3 Acknowledgments

* [Joe Armstrong](https://joearms.github.io/), Ericsson
* [Mark Miller](https://github.com/erights), Agoric
* [Peter Alvaro](https://github.com/palvaro), UC Santa Cruz
* [Joe Hellerstein](https://github.com/jhellerstein), UC Berkley
* [Juan Benet](https://github.com/jbenet/), Protocol Labs
* [Christine Lemmer-Webber](https://github.com/cwebber), Spiritely Institute
* [Quinn Wilton](https://github.com/QuinnWilton), Fission
* [Luke Marsden](https://github.com/lukemarsden), Protocol Labs
* [David Aronchick](https://www.davidaronchick.com/), Protocol Labs
* [Eric Myhre](https://github.com/warpfork), Protocol Labs
* [Irakli Gozalishvili](https://github.com/Gozala), DAG House
* [Hugo Dias](https://github.com/hugomrdias), DAG House
* [Mikeal Rogers](https://github.com/mikeal/), DAG House
* Steven Allen
* Melanie Riise
* Christine Lemmer-Webber
* Peter Alvaro
* Juan Benet

# 4 Prior Art

* [Docker Job Controller](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
* BucketVM (UCAN Invocation)
* [WarpForge "Formula" v1](https://github.com/warpfork/warpforge/blob/master/examples/110-formula-usage/example-formula-exec.md)
* [Bacalhau Job Spec](https://github.com/filecoin-project/bacalhau/blob/8568239299b5881bc90e3d6be2c9aa06c0cb3936/pkg/model/job.go#L192)
Bloom
AquaVM
PACT/HydroLogic

It is not possible to mention the separation of effects from computation without mentioning the algebraic effect lineage from Haskell, OCaml, and Eff. While the overall system looks quite different from the their type-level effects, this work owes a debt to at least Gordon Plotkin and John Power's work on [computational effects](https://homepages.inf.ed.ac.uk/gdp/publications/Overview.pdf), 

# FIXME STASH

https://www.tweag.io/blog/2020-09-10-nix-cas/

https://www.ams.org/journals/tran/1936-039-03/S0002-9947-1936-1501858-0/S0002-9947-1936-1501858-0.pdf

* confluence
* differential dataflow
* map/reduce
* actors & loops
* captp/ocapn
* Enqueuing new jobs in output
IPVM implements a capability model based on keys, linked certificates, and CapTP. Executor certificate negotiation MUST happen during negotiation, 

