# Pandora-Maze-Autonomous-Worlds-Demo

## Project Description
Pandora Maze is a Match-3 roguelike game fully on-chain, incorporating elements of Greek characters. There are two game modes in Pandora Maze: Competition Mode, Free Mode, and in Free Mode, players can create custom levels, giving the game rich openness and composability.

### Game Mode
1.Competition Mode: The game has pre-set different levels, and all players participate in the challenge together. Players need to eliminate the same Greek character blocks to get enough points to pass the level. The next level will only be unlocked when the number of players passing the level reaches a standard. Each level has different challenge objectives and optimal solutions, players need to eliminate as many blocks as possible within a specified number of steps to get higher scores and pass rewards. After each level ends, players can check their scores and compare with other players to see who is the best solver of this level.

2.Free Mode: Players can customize any string as a random seed for the blockchain to generate a brand-new level. Players can challenge this level an unlimited number of times, refreshing their level points by finding the global optimal solution. This level can also be challenged by any other player, to support players creating custom competition.

### Game Features
1.Random Generation: Every time a new game is started, the game content is randomly generated. Therefore, each experience a player has in the game will be unique and non-replicable.

2.Unidirectional Progress: In a single game level, every move made by the player is irreversible. The game progression is one-way.

3.Non-linear Gameplay: Each action taken by the player can lead to different game outcomes.

4.Permissionless composability: Players can fully customize the configuration of each game session, such as the random seed, the number of words, the number of layers, the size of the limit slot, and so on, to combine different levels into a series of their own adventures.

## How it's Made
Here's an overview of our tech stack and how we put it all together:

Smart Contract: We use the Solidity programming language. Solidity is a high-level language with strong code readability and easy understanding. Additionally, we used the Foundry framework in our development process. Foundry uses only Solidity, enabling smart contract engineers to complete smart contract writing, testing, and deployment solely with Solidity. Because tests are written in Solidity, we can focus on Solidity itself without worrying about the learning curve or extra bugs that might come with testing in JavaScript/TypeScript/Python, etc.

Front-end: We use LayaAir3 as our front-end display rendering engine. In combination with the convenient APIs provided by the MUD framework's std-client, we can build fast, responsive, modular, and aesthetically pleasing interfaces. This engine, based on the Node.js runtime environment, perfectly adapts to the web3 development environment and seamlessly interacts with smart contracts and backend services.

Backend: We use third-party libraries like MUD framework's std-contracts to construct the server framework, allowing us to quickly develop game content. This lets us focus more on the creation and contemplation of the game's core content. The large number of projects launched using this framework (MUD) attests to its performance and security.

CHATGPT-4 & Cursor: To accelerate our development process, we occasionally consult OpenAI's advanced language model for advice. Through communication with OpenAI, we gain inspiration and refine our products.

Midjourney: Our team doesn't include graphic designers, so we use Midjourney's intelligent AI to generate the artistic materials needed for the game's front-end. As you can see, it performs remarkably well.

Unipass: We have incorporated the Unipass SDK's account abstraction technology into the game, allowing users to log in using their email instead of a wallet address. It also supports user-customized token types for paying blockchain gas costs.

Through these tools, we believe we can create a fully composable on-chain game, demonstrating the infinite potential of the blockchain.

## The project structure is as follows

```shell
├── package.json                    --- project configs
├── packages
│   ├── client                      --- client project
│   │   ├── assets
│   │   │   └── resources           --- resources of client
│   │   │       ├── atlas
│   │   │       ├── font
│   │   │       ├── prefab
│   │   │       ├── scene           --- game scene files 
│   │   │       └── ui              --- textures
│   │   ├── client.laya
│   │   ├── engine
│   │   │   └── types
│   │   ├── package.json            --- client project configs
│   │   ├── settings
│   │   ├── src
│   │   │   ├── common
│   │   │   ├── contracts           --- contracts abi
│   │   │   │   ├── mud.config.ts
│   │   │   │   ├── types
│   │   │   │   └── worlds.json
│   │   │   ├── game                --- game logic codes
│   │   │   ├── mud
│   │   │   └── scene
│   │   └── tsconfig.json
│   └── contracts                       --- contract project
│       ├── foundry.toml
│       ├── mud.config.ts
│       ├── package.json
│       ├── script
│       │   └── PostDeploy.s.sol
│       ├── src                         --- contract source codes
│       │   ├── codegen
│       │   │   ├── Tables.sol
│       │   │   ├── Types.sol
│       │   │   ├── tables
│       │   │   │   ├── GameConfigComponent.sol
│       │   │   │   ├── PlayerComponent.sol
│       │   │   │   ├── RankComponent.sol
│       │   │   │   ├── ScoreComponent.sol
│       │   │   │   ├── SeedComponent.sol
│       │   │   │   └── StageComponent.sol
│       │   │   └── world
│       │   │       ├── IJoinGameSystem.sol
│       │   │       ├── IPlayGameSystem.sol
│       │   │       └── IWorld.sol
│       │   ├── lib
│       │   │   ├── GameConfigInitializer.sol
│       │   │   ├── LibBlock.sol
│       │   │   ├── LibConfig.sol
│       │   │   └── LibRand.sol
│       │   └── systems
│       │       ├── JoinGameSystem.sol
│       │       └── PlayGameSystem.sol
│       ├── test                        --- contract test codes
│       │   ├── LibBlock.t.sol
│       │   └── LibConfig.t.sol
│       ├── tsconfig.json
│       └── worlds.json                 --- mud config
```
