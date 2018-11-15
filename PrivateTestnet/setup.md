# 1. Create a new genesis block

## puppeth

### Type a name for your new network

### Select option 2 and select ethhash

### type 2 to export the file

# 2. Create a chain

## geth --datadir . init GenesisBlock.json

# 3. Create some new accounts

## geth --datadir . account new

# 4. Ensure that the accounts have been created

## geth --datadir . account list

# 5. Create a startnode.sh file

## Run it

## 6. In yout truffle config define a new network and set it's gas property to 4612388 and in the exported object add a new field called solc like here

solc: {
optimizer: {
enabled: true,
runs: 200
}
}
