# IPVM Invocation Specification v0.1.0

## Editors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Authors

* [Brooklyn Zelenka](https://github.com/expede), [Fission](https://fission.codes)

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).

# 0 Abstract

An IPVM invocation is the container for everything required to run an IPVM Task. An invocation can be derived entirely from its linked capabilities.

It specifies a resource and what action to perform with it, capability proof(s) for those actions, and ____.

# 1 Introduction

# 2 Format

``` json
{
  "type": "ucan/invoke",
  "caps": [ "Qm123", "Qm456" ],
  "signature": 0xC0FFEE
}
```

Expanded:

``` json
{
  "type": "ucan/invoke",
  "run": {
    "left": {
      "cap": {
        "iss": "did:key:zRequestor",
        "aud": "did:key:zRunner",
        "exp": 999999,
        "att": {
          "dns://foo.exmaple.com?TYPE=TXT": {
            "crud/update": [
              { "to": "hello world" }
            ],
            "crud/read": []
          }
        }
      }
    },
    "right": {
      "cap": {
        "iss": "did:key:zRequestor",
        "aud": "did:key:zRunner",
        "exp": 999999,
        "att": {
          "dns://foo.exmaple.com?type=txt": {
            "crud/update": [
              { "to": "hello world" }
            ],
            "crud/read": []
          }
        }
      }
    },
    "end": {
      "cap": {
        "iss": "did:key:zrequestor",
        "aud": "did:key:zrunner",
        "exp": 999999,
        "att": {
          "dns://foo.exmaple.com?type=txt": {
            "crud/update": [
              { "to": "hello world" }
            ],
            "crud/read": []
          }
        }
      },
      "after": ["left", "right"]
    }
  },
  "siganture": 0xCOFFEE
}
```

