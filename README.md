# ERC-20 sur Starknet avec Cairo 

Adresse du smart contract sur `Sepolia` : 
```
Contract deployed:
0x0595a40955821af987d7d711305c1ff02dcde786a43a7ed0f1a00d9f9a04d9a3
```

# Build 

```bash
scarb build
```


# Déploiement sur Starknet 
## Préparer le déploiement(Facultatif)
Soyez sur que votre `account.json` et `keystore.json` sont bien configurés. 

```bash
export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/account.json
export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/keystore.jso
```

## Declaration 
```bash
starkli declare target/dev/erc_20_MonSmartContract.contract_class.json --network sepolia
```

## Déploiement
```bash
erc_20 % starkli deploy $CLASS_HASH $ADRESSE_WALLET_SUPPLY_INITIAL --network sepolia
```

# Inclusion dans ArgentX
Soyez sur d'être sur Sepolia(et non `mainnet`)  puis cliquez sur `Add new token` puis entrez l'adresse du smart contract.
