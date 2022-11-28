
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

## 5.4 Randomness

Randomness is RECOMMENDED to be souiderived from a trused high-entropy source, such as [drand](https://drand.love/).

``` json
{
  "type": "ipvm/effect",
  "with": "ipns://QmbCMUZw6JFeZ7Wp9jkzbye3Fzp2GGcPgC3nmeUjfVF87n",
  "do": "crud/read" 
}
```






NOTE TO SELF: on `crud/read`, we probably need some kind of max file size limit (and timeout obvs)





# 4 Effects

The contract for effects is different from pure computation. As effects by definition interact with the "real world". These may be either commands or queries. Exmaples of effects include reading from DNS, sending an HTTP POST request, running a WASI module with network access, or receieving a random value.

The `with` field MAY be filled from a relative value (previous step)

| Field    | Type    | Description                | Required | Default |
|----------|---------|----------------------------|----------|---------|
| `v`      | SemVer  | IPVM effect schema version | No       | `0.1.0` |
| `args`   | `[{}]`  |                            | No       | `[]`    |



## 4.3 JSON Example

``` json
{
  "using": "docker:1:Qm12345", // Or something... wasm:Qm12345?
  "do": "executable/run",
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

# 3 Pure Wasm

Treated as a black box, the deterministic subset of Wasm MUST be treated as a pure function, with no additional handlers or other capabilities directly available via WASI or similar aside from the ability to read content addressed data.

Note that while the function itself is pure, as is dereferencing content-addressed data, the function MAY fail if the CID is not available to the runner.

The Wasm configuration MUST extend the core task type as follows:

| Field  | Type                  | Description                               | Required | Default |
|--------|-----------------------|-------------------------------------------|----------|---------|
| `v`    | SemVer                | The Wasm module's Wasm version            | No       | `0.1.0` |
| `func` | `String or OutputRef` | The function to invoke on the Wasm module | Yes      |         |
| `args` | `[{String : Any}]`    | Arguments to the Wasm executable          | Yes      |         |
  
## 3.2 IPLDS Schema

``` ipldsch
type WasmTask struct {
  v    SemVer
  func String -- Function name to invoke 
  args [Any]  -- Positional arguments FIXME **for now** -- we need to figure out WIT, I know
}
```
