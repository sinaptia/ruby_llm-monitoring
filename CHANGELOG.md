# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
