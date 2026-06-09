# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Drop `ruby_llm-instrumentation` dependency in favor of the built-in instrumentation available in `ruby_llm >= 1.16`. [#87](https://github.com/sinaptia/ruby_llm-monitoring/pull/87) [@patriciomacadden](https://github.com/patriciomacadden)

## [0.3.2] - 2026-04-07

### Fixed

- Fix `#set_cost` crash when using `RubyLLM.context`. [#66](https://github.com/sinaptia/ruby_llm-monitoring/pull/66) [@bborn](https://github.com/bborn)

## [0.3.1] - 2026-03-07

### Added

- Support Trilogy adapter in JSON extraction migration helpers. [#43](https://github.com/sinaptia/ruby_llm-monitoring/pull/43) [@zavan](https://github.com/zavan)

## [0.3.0] - 2026-02-27

### Changed

- Contemplate thinking tokens in cost calculation. [#40](https://github.com/sinaptia/ruby_llm-monitoring/pull/40) [@patriciomacadden](https://github.com/patriciomacadden)

### Fixed

- Fix cost calculation when input or output tokens aren't in the payload. [#30](https://github.com/sinaptia/ruby_llm-monitoring/pull/30) [@UnderpantsGnome](https://github.com/UnderpantsGnome)
- The create events migration was wrong for mysql2 and postgresql. [#35](https://github.com/sinaptia/ruby_llm-monitoring/pull/35) [@patriciomacadden](https://github.com/patriciomacadden)
- Add missing assets to precompilation when using sprockets. [@patriciomacadden](https://github.com/patriciomacadden)

## [0.2.0] - 2026-02-10

### Added

- Events controller. [#23](https://github.com/sinaptia/ruby_llm-monitoring/pull/23) [@patriciomacadden](https://github.com/patriciomacadden)

### Changed

- New metrics controller that allows defining custom charts. [#25](https://github.com/sinaptia/ruby_llm-monitoring/pull/25) [@patriciomacadden](https://github.com/patriciomacadden)

### Fixed

- Events failed to be saved when RubyLLM::Chat had attachments. Now the payload drops the chat and the response objects before saving. Fixes [#18](https://github.com/sinaptia/ruby_llm-monitoring/issues/18). [#29](https://github.com/sinaptia/ruby_llm-monitoring/pull/29) [@patriciomacadden](https://github.com/patriciomacadden)
- Use the correct mysql2 adapter. Fixes [#31](https://github.com/sinaptia/ruby_llm-monitoring/issues/31). [#33](https://github.com/sinaptia/ruby_llm-monitoring/pull/33) [@patriciomacadden](https://github.com/patriciomacadden)
