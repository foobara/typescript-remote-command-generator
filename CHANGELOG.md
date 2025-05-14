## [0.0.22] - 2025-05-14

- Fix bug hard-coding wrong GetCurrentUser command in setup.ts

## [0.0.21] - 2025-05-13

- Implement Query/QueryCache/useQuery to use commands as data sources and share that data across components

## [0.0.20] - 2025-05-03

- Add a potentially missing require_relative

## [0.0.19] - 2025-04-25

- Fix bugs causing issues with generating command inputs for entities or custom types

## [0.0.18] - 2025-04-15

- Don't make use of Model/Entity in input types
- Add toJSON methods to Model and Entity for proper serialization when building inputs

## [0.0.17] - 2025-04-08

- Handle undefined/empty inputs in Inputs.ts.erb

## [0.0.16] - 2025-03-31

- Add a bunch of special-case support for Foobara::Auth domain convenience

## [0.0.15] - 2025-03-30

- Better error handling in RemoteCommand

## [0.0.14] - 2025-03-30

- Implement Auth domain support in RemoteCommand

## [0.0.13] - 2025-03-17

- Fix bug incorrectly generating model typescript for detached entities
- Fix bug preventing Loaded/Unloaded entity import from being destructured properly
- Handle errors with prefixes
- Include custom types and models in error generator dependencies
- Fix bug preventing allow_nil from having an effect

## [0.0.12] - 2025-03-02

- Add ability to ask RemoteCommand for its state and outcome

## [0.0.11] - 2025-02-26

- Implement support for command result types that are arrays

## [0.0.10] - 2025-02-21

- Include org/domain prefixes in command URLs

## [0.0.9] - 2025-02-21

- Fix a bug where we don't use the name of a custom type when we could

## [0.0.8] - 2025-02-21

- Make sure entity/detached_entity/model are used properly in several places

## [0.0.7] - 2025-01-06

- Bump Ruby to 3.4.1

## [0.0.6] - 2024-08-22

- Fix remaining naming bug in model templates

## [0.0.5] - 2024-08-22

- Fix several naming/import issues in templates

## [0.0.4] - 2024-08-22

- Add type generators to command result generator
- Add type generators to domain generator
- Attempt to fix botched nested type paths

## [0.0.2] - 2024-08-21

- Add a TypeGenerator for custom non-model types

## [0.0.1] - 2024-06-17

- Add Apache-2.0 license

## [0.0.0] - 2023-11-28

- Project birth
