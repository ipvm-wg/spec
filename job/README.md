# IPVM Job Spec

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Blaine Cook](https://github.com/blaine), [Fission](https://fission.codes)
* [Zeeshan Lakhani](https://github.com/zeeshanlakhani), [Fission](https://fission.codes)
* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)
    
## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

An IPVM "job" is a declarative description of WebAssembly and managed effects to be run by the IPVM runtime.

# 1 Motivation

IPVM provides a deterministic-by-default, content addressed execution environment. Execution may always be run locally, but there are many cases where remote exection is desirable: access to large data, faster processors, trusted execution environments, or access to specialized hardware, among others.

## 1.1 Minimizing Complexity

> Every application has an inherent amount of irreducible complexity. The only question is: Who will have to deal with it — the user, the application developer, or the platform developer?
> -- [Tesler's Law](https://en.wikipedia.org/wiki/Law_of_conservation_of_complexity)

With "jobs" as the unit of execution, programmers gain flexible cache granularity, parallelism, and ___. Partial failure is Transactionality 

* [Convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration).


# 2 Dataflow Graph

* Automatic (and deterministic) parallelism
* Dataflow / job graph
* Effects System
* Partial Failure & Transactionality 
* Auth: SPKI & object capabilities

* Wasm execution in depth
* Spec format IPLD
  * Input addressing

# 3 Acknowledgments

* [Quinn Wilton](https://github.com/QuinnWilton), Fission
* [Eric Myhre](https://github.com/warpfork), Protocol Labs
* [Luke Marsden](https://github.com/lukemarsden), Protocol Labs
* [David Aronchick](https://www.davidaronchick.com/), Protocol Labs
* [Irakli Gozalishvili](https://github.com/Gozala), DAG House
* [Hugo Dias](https://github.com/hugomrdias), DAG House
* [Mikeal Rogers](https://github.com/mikeal/), DAG House
* [Juan Benet](https://github.com/jbenet/), Protocol Labs
* [Christine Lemmer-Webber](https://github.com/cwebber), Spiritely Institute
* [Mark Miller](https://github.com/erights), Agoric
* [Peter Alvaro](https://github.com/palvaro), UC Santa Cruz
* [Joe Hellerstein](https://github.com/jhellerstein), UC Berkley

# 4 Prior Art

* [Docker Job Controller](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
* BucketVM (UCAN Invocation)
* [WarpForge "Formula" v1](https://github.com/warpfork/warpforge/blob/master/examples/110-formula-usage/example-formula-exec.md)
* [Bacalhau Job Spec](https://github.com/filecoin-project/bacalhau/blob/8568239299b5881bc90e3d6be2c9aa06c0cb3936/pkg/model/job.go#L192)






https://www.tweag.io/blog/2020-09-10-nix-cas/
