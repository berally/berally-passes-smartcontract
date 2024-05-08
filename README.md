# Berally
## Repository
We have a main contract:
`BerallyPasses`: Contract for managers create passes, users buy and sell the passes.

## Sequence of Events
A `BerallyPasses` 'contract allows managers to create passes. It allows users to perform buying and selling of passes.

### 1. Init the first pass
* The entry point `buyPasses` in `BerallyPasses` contract allow managers to create the first pass before other users can buy. With the factor parameter, managers can adjust the price for their passes.

### 2. Buy passes
* The entry point `buyPasses` in `BerallyPasses` contract also allow users to buy passes with prices that change based on the balance of passes.

### 3. sellPasses
* The entry point `sellPasses` in `BerallyPasses` contract allow users to sell their passes.

## Build
```bash
yarn compile
```

## Configuration
See example in `config/*.config.ts`

## Deploy
* Before deploy contract, you need ensure add enviroment variable in `.env` (see `.env.example`)
* Deploy BerallyPasses on Berachain
```bash
yarn deploy:BerallyPasses:berachain
```

