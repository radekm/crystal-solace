# Solace binding for Crystal

Very basic binding to Solace C SDK.

Since I'm not allowed to redistribute Solace C SDK
you have to download it manually and place following libraries
into `solclient` directory:

- `libsolclient.a` + real library to which symlink points,
- `libssl.a`,
- and `libcrypto.a`.

## Goals for near future

The goal is to support read-only access via non-blocking APIs
with discard indications and without topic dispatch and
message eliding which don't work well with discard indications.



- [x] Initialize API, create context and session.
- [x] Subscribe to topics.
- [ ] Unsubscribe from topics.
- [x] Destroy context and session.
- [ ] Read message properties.
- [ ] Free message.
- [ ] Provide both raw binding and higher level binding.
- [x] Support Mac.
- [x] Support Linux.
