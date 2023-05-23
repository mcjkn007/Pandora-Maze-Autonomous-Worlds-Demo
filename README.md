# Pandora-Maze-Autonomous-Worlds-Demo

This is the demo project of Pandora-Maze-Autonomous-Worlds

The project structure is as follows

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
