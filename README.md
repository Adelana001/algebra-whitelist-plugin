# Whitelist Algebra Plugin
Adds support for limiting interaction with pools to specific accounts. Note that the account in this case is the account receiving the tokens.

The reason for this is that, we can have "Caller" or "Peripheral" smart contracts that make several calls on behalf of an account. This contract's access to the pool shouldn't affect any other users. Hence the reason for this decision.

For example,
- `ContractA` is a peripheral account that executes swap orders on behalf of several users to cover gas costs and is funded by a community
- `AccountA` is an account that is whitelisted
- `AccountB` is an account that isn't whitelisted

If `ContractA` is to call `pool.swap` with `AccountA` as the receipient, in reality, `AccountA` is the one trading, same with `AccountB`. It's therefore sensible to restrict access based on the receipient address rather than the sender address.
This is demonstrated in the tests. ([`test/Whitelist.t.sol`](test/WhitelistPlugin.t.sol))
## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

