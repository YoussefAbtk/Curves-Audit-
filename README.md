
# Curves audit details
- Total Prize Pool: $36,500 in USDC
  - HM awards: $24,750 in USDC
  - Analysis awards: $1,500 in USDC
  - QA awards: $750 in USDC
  - Bot Race awards: $2,250 in USDC
  - Gas awards: $750 in USDC
  - Judge awards: $3,600 in USDC
  - Lookout awards: $2,400 in USDC
  - Scout awards: $500 in USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2024-01-curves/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts January 8, 2024 20:00 UTC
- Ends January 15, 2024 20:00 UTC

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-01-curves/blob/main/4naly3er-report.md).

Automated findings output for the audit can be found [here](https://github.com/code-423n4/2024-01-curves/blob/main/bot-report.md) within 24 hours of audit opening.

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._


# Overview


## Scoping detail

The audit will encompass the following files, each integral to the functioning of the protocol:

1. **Curves.sol**: This is the primary file of the Curves protocol. It contains the core logic and functions that define the overall behavior and rules of the system. This file started as a fork of friend.tech FriendtechSharesV1.sol

2. **CurvesERC20.sol**: This file defines the ERC20 token that will be created upon exporting a Curve token. It outlines the token's properties and behaviors consistent with the ERC20 standard.

3. **CurvesERC20Factory.sol**: Serving as an ERC20 factory, this file abstracts the logic for ERC20 token creation. Its primary purpose is to streamline the token creation process and reduce the overall footprint of the protocol, ensuring efficiency and scalability.

4. **FeeSplitter.sol**: This script manages the distribution of fees. It is responsible for the fair and accurate division of transaction fees amongst token holders, in line with the protocol's incentive structure.

5. **Security.sol**: This file standardizes the security criteria for the protocol. It includes protocols and measures designed to safeguard the system against vulnerabilities and ensure compliance with established security standards.

Each of these files plays a crucial role in the protocol’s architecture and functionality. The audit will methodically evaluate them for security, efficiency, and adherence to best practices in smart contract development.

## Summary

The Curves protocol, an extension of friend.tech, introduces several innovative features. For context on friend.tech, consider this insightful article: [Friend Tech Smart Contract Breakdown](https://medium.com/valixconsulting/friend-tech-smart-contract-breakdown-c5588ae3a1cf). Key enhancements in the Curves protocol include:

1. Token Export to ERC20: This pivotal feature allows users to transfer their tokens from the Curves protocol to the ERC20 format. Such interoperability significantly expands usability across various platforms. Within Curves, tokens lack decimal places, but when converted to ERC20, they adopt a standard 18-decimal format. Importantly, users can seamlessly reintegrate their ERC20 tokens into the Curves ecosystem, albeit only as whole, integer units.

2. Referral Fee Implementation: Curves empowers protocols built upon its framework by enabling them to earn a percentage of all user transaction fees. This incentive mechanism benefits both the base protocol and its derivative platforms.

3. Presale Feature: Learning from the pitfalls of friend.tech, particularly issues with frontrunners during token launches, Curves incorporates a presale phase. This allows creators to manage and stabilize their tokens prior to public trading, ensuring a more controlled and equitable distribution.

4. Token Holder Fee: To encourage long-term holding over short-term trading, Curves introduces a fee distribution model that rewards token holders. This fee is proportionally divided among all token holders, incentivizing sustained investment in the ecosystem.

These additions by Curves not only enhance functionality but also foster a more robust and inclusive financial ecosystem.

## Documentation
There's no official friend.tech documentation but there's a lot of great articles. Here you can find some of them:

[Friend Tech Smart Contracts](https://basescan.org/address/0xcf205808ed36593aa40a44f10c7f7c2f67d4a4d4#code). 

[Friend Tech Smart Contract Breakdown](https://medium.com/valixconsulting/friend-tech-smart-contract-breakdown-c5588ae3a1cf). 

[Understanding Friend Tech through Smart Contracts](https://ada-d.medium.com/understanding-friend-tech-through-smart-contracts-edac5d98cd49). 



# Scope


| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| [contracts/Curves.sol](https://github.com/code-423n4/2024-01-curves/blob/main/contracts/Curves.sol) | 413 | | openzeppelin |
| [contracts/FeeSplitter.sol](https://github.com/code-423n4/2024-01-curves/blob/main/contracts/FeeSplitter.sol) | 95 | | openzeppelin |
| [contracts/Security.sol](https://github.com/code-423n4/2024-01-curves/blob/main/contracts/Security.sol) | 23 | | |
| [contracts/CurvesERC20.sol](https://github.com/code-423n4/2024-01-curves/blob/main/contracts/CurvesERC20.sol) | 14 | | openzeppelin |
| [contracts/CurvesERC20Factory.sol](https://github.com/code-423n4/2024-01-curves/blob/main/contracts/CurvesERC20Factory.sol) | 8 | | |

## Out of scope

Any file not listed in the scope above is out of scope.

# Additional Context

- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Please list specific ERC20 that your protocol is anticipated to interact with. Could be "any" (literally anything, fee on transfer tokens, ERC777 tokens and so forth) or a list of tokens you envision using on launch.
- [ ] Please list specific ERC721 that your protocol is anticipated to interact with.
- [ ] Which blockchains will this code be deployed to, and are considered in scope for this audit?
- [ ] Please list all trusted roles (e.g. operators, slashers, pausers, etc.), the privileges they hold, and any conditions under which privilege escalation is expected/allowable
- [ ] In the event of a DOS, could you outline a minimum duration after which you would consider a finding to be valid? This question is asked in the context of most systems' capacity to handle DoS attacks gracefully for a certain period.
- [ ] Is any part of your implementation intended to conform to any EIP's? If yes, please list the contracts in this format: 
  - `Contract1`: Should comply with `ERC/EIPX`
  - `Contract2`: Should comply with `ERC/EIPY`

## Attack ideas (Where to look for bugs)
*List specific areas to address - see [this blog post](https://medium.com/code4rena/the-security-council-elections-within-the-arbitrum-dao-a-comprehensive-guide-aa6d001aae60#9adb) for an example*

## Main invariants
*Describe the project's main invariants (properties that should NEVER EVER be broken).*

## Scoping Details 

```
- If you have a public code repo, please share it here: https://github.com/roll-network/curves  
- How many contracts are in scope?: 5   
- Total SLoC for these contracts?: 660  
- How many external imports are there?: 5  
- How many separate interfaces and struct definitions are there for the contracts within scope?: 5  
- Does most of your code generally use composition or inheritance?: Composition   
- How many external calls?: 0   
- What is the overall line coverage percentage provided by your tests?: 100
- Is this an upgrade of an existing system?: True - Fork from tech.finance
- Check all that apply (e.g. timelock, NFT, AMM, ERC20, rollups, etc.): Uses L2, ERC-20 Token 
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?: False   
- Please describe required context:   
- Does it use an oracle?: No
- Describe any novel or unique curve logic or mathematical models your code uses: The curve is the same as tech.finance 
- Is this either a fork of or an alternate implementation of another project?:   
- Does it use a side-chain?:
- Describe any specific areas you would like addressed:
```

# Tests

See [install.md](https://github.com/code-423n4/2024-01-curves/blob/main/install.md)