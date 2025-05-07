# ViewAttributeMerge

A Ruby gem for merging HTML view attributes with support for Stimulus 2.0 conventions.

## Features

- Merges HTML attributes from multiple sources
- Handles and concatenates Stimulus 2.0 data attributes:
  - `data-controller`
  - `data-action` 
  - `data-[controller]-target`
- Supports nested data/aria attributes
- Properly concatenates class attributes
- Maintains attribute precedence

## Installation

Add to your Gemfile:
```ruby
gem 'view_attribute_merge'
```

## Usage

```ruby
attributes = ViewAttributeMerge.attr_merge(
  { class: "btn", data: { controller: "modal" } },
  { class: "btn-primary", "data-action": "click->modal#open" },
  { "data-modal-target": "dialog" }
)

# Returns:
# {
#   class: ["btn", "btn-primary"],
#   data: {
#     controller: "modal",
#     action: "click->modal#open", 
#     target: "dialog"
#   }
# }
```

### Stimulus 2.0 Support

The gem follows Stimulus 2.0 conventions:
- `data-controller` values are concatenated
- `data-action` values are concatenated  
- `data-[controller]-target` values are concatenated

```ruby
# Proper Stimulus 2.0 format:
{ "data-controller": "controller", "data-controller-target": "element" }

# Legacy format (not supported):
{ "data-target": "controller.element" }
```

## Development

After checking out the repo:
1. Run `bin/setup` to install dependencies
2. Run `bundle exec rspec` to execute tests
3. Run `bundle exec rubocop` to check code style
4. Run `bundle exec standardrb` to verify Standard Ruby style

### Code Quality

The project uses:
- [Rubocop](https://github.com/rubocop/rubocop) for linting
- [Standard](https://github.com/testdouble/standard) for formatting
- [SimpleCov](https://github.com/simplecov-ruby/simplecov) for test coverage (minimum 90%)
- [Solargraph](https://github.com/castwide/solargraph) for documentation

### Test Coverage

To generate a coverage report:
```bash
COVERAGE=true bundle exec rspec
```
Open `coverage/index.html` to view the report.

### Contributing

1. Fork the project
2. Create a feature branch
3. Add tests for your changes
4. Ensure all tests pass and coverage remains at 90%+
5. Submit a pull request

## License

MIT License - see LICENSE.txt
