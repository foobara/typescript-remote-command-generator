## [1.2.5] - 2026-01-27

- Fix circular dependency that happens if an item from this domain collides

## [1.2.4] - 2026-01-26

- Fix bug where we include models/entities from command inputs

## [1.2.3] - 2026-01-24

- Default the project_directory to "." instead of the output_directory

## [1.2.2] - 2026-01-24

- Add support for an app model named Model, which collide's with Foobara's Model
- Fixes a bug when the superclass we import collides with dependencies
- Fixes a bug where a dependency collides with something we're generating

## [1.2.1] - 2025-12-19

- Handle some .foobara_delegate and #path deprecation warnings

## [1.2.0] - 2025-11-06

- If an attribute isn't required but has a default, it will have a non-required create
  interface but a required read interface. This updates the types to reflect that for
  convenience to avoid pointless null checks.

## [1.1.7] - 2025-11-02

- Make CommandCastResultGenerator's interpretation of atom? match other generators

## [1.1.6] - 2025-10-17

- Dirty all queries on login/logout, not just GetCurrentUser
- Remove no-longer needed /setup.ts file generation

## [1.1.5] - 2025-10-15

- Implement castJsonResult
- Fix various problems with Model and subclass constructors
- Memoize various #model_generators, #dependencies, #dependency_roots
- Cache generator creation
- Add ruby-prof and term trap spec support files

## [1.1.4] - 2025-10-02

- Don't give warning about importing domain/setup.ts if it already has been added to index.tsx

## [1.1.2] - 2025-09-27

- Fix busted Atom/Aggregate entity import generation

## [1.1.1] - 2025-08-25

- Improve location of generated types and their errors

## [1.1.0] - 2025-08-22

- Handle Foobara 0.1.0 type declarations

## [1.0.1] - 2025-08-04

- Properly handle no result type with a Result type of null
- Add "date" to list of supported types and use Date for it

## [1.0.0] - 2025-07-31

- Create never types for Error/PossibleErrors when command cannot error
- Support built-in non-extended attributes type

## [0.0.24] - 2025-05-14

- Fix bugs with setup.ts

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
