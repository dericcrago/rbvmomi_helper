# RbVmomiHelper

[![Build Status](https://travis-ci.org/dericcrago/rbvmomi_helper.svg?branch=master)](https://travis-ci.org/dericcrago/rbvmomi_helper)
[![codecov.io](https://codecov.io/github/dericcrago/rbvmomi_helper/coverage.svg?branch=master)](https://codecov.io/github/dericcrago/rbvmomi_helper?branch=master)

A set of helper methods for [RbVmomi](https://github.com/vmware/rbvmomi).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbvmomi_helper'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install rbvmomi_helper
```

## Usage

```ruby
require 'rbvmomi_helper'

# Find a vm like you normally would using RbVmomi
# Then use the helper methods
vm.configure_auth('root', 'password')
vm.put_file('sleep.sh', '/tmp/sleep.sh')
vm.start_program('/bin/bash', '/tmp/sleep.sh')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dericcrago/rbvmomi_helper.
