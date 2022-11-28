
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
