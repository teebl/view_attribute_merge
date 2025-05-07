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
1. Run `bin/setup`
2. Run tests with `bundle exec rspec`
3. Make changes with tests

## License

MIT License - see LICENSE.txt
