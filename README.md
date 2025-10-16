# Comunifi - Tor + EURe Request Demo

Nostr + Crypto + Tor = ❤️

## Problem

Open source projects, content creators and non-profit projects often operate cross-borders and have a community with which they communicate. They are forced to use tools where the data and accounts are controlled by corporations. 

They also often need to allocate/distribute resources. Stablecoins make this very easy.

## Solution

We’ve built a social coordination tool that combines a decentralized data network (Nostr) with crypto — creating a foundation for community finance (**Comunifi!**), where communication, coordination, and funding all live in one decentralized ecosystem.

Think Telegram or Reddit meets Web3, where communities can fund and reward participation through native tokenomics.

Exploring grassroots community finance — empowering local groups, co-ops, and DAOs with tools for collective action and transparent contribution systems.

Focusing on resilience and privacy by allowing users to connect their clients to decentralized Nostr relays over Tor, enabling optional, censorship-resistant communication.

### Social Layer - Nostr

Usage of Nostr for the decentralized messaging layer. Nostr allows us to communicate in real time over a standard protocol. It also allows us to send json which can then be used to trigger on-chain actions.

### Blockchain Layer - Gnosis + ERC4337 Account Abstraction

Usage of the Citizen Wallet bundler to submit transactions.

EURe on Gnosis.

### Desktop Client - Flutter

Run on your computer without needing permission from an app store to install.

### Privacy - Tor

The desktop client connects through Tor ensuring we maximize privacy for users.

### Demo

A working prototype showcasing on-chain group funding, Nostr-based messaging, and Tor-routed relay connectivity.

Two clients running through Tor against a single relay.

One client is located in Brussels, the other client is located in Minneapolis.

1. Run Comunifi
2. Connect to Tor
3. Send message
4. Receive message
5. Send request for 25 EURe
6. Request is fulfilled
7. Receive 25 EURe


Tx hash of the transaction from the demo: [0xc0b5c23b2eab55ff141748e23a77bf26f8e21b197b5d97f96ab2d603be1ee945](https://gnosisscan.io/tx/0xc0b5c23b2eab55ff141748e23a77bf26f8e21b197b5d97f96ab2d603be1ee945)

€25 sent from Minneapolis to Brussels, coordinated through Nostr privately through Tor.

### Getting Started

### Relay
```
cd relay

cp .env.example .env

docker compose up db
```

Run the relay using the launch config from VS Code or Cursor. Hit the play button.

### Ngrok

```
ngrok http 3334
```

### Tor

```
ngrok http 3334
```

### App
```
cd app

flutter pub get

cp .env.example .env

flutter run -d macos
```


Put the ip address you get from ngrok as RELAY_URL.

## Potential Impact

Making global digital coordination as easy as starting a whatsapp group. 

This will enable people/projects/causes to collaborate on in way where they are not trapped in the communication tool. Unlike whatsapp/signal/telegram, the Nostr protocol is open and standardized, allowing people to move data and build their own clients.

Making send stablecoins as easy to use as the request flow we demoed will make crypto much easier to integrate into all sorts of smart flows.

The Tor layer is icing on the cake and enables more robust privacy.







