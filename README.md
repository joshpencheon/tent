tent [![Build Status](https://travis-ci.org/joshpencheon/tent.svg?branch=master)](https://travis-ci.org/joshpencheon/tent) [![Gem Version](https://badge.fury.io/rb/tent.svg)](http://badge.fury.io/rb/tent)
======

Tent is a simple library for buffering calls to an underlying object conditionally.

Installation
=====

Tent is available as a gem, so simply run:

```
$ gem install tent
```

Alternatively, you can add `tent` to your Gemfile:

```ruby
gem 'tent'
```

Followed by:

```
$ bundle install
```

Usage
=====

```ruby
# Wrap an underlying object, like `Rails.logger`:
Tent.cover(Rails.logger) do |cover|
  # Delegate calls to the logger object:
  cover.info('For your information')
  cover.debug('this is boring')
  cover.debug('not helpful')

  # Use `discard!(*filters)` to drop matching
  # calls from the buffer:
  cover.discard!(:debug) unless having_problems?

  # Use `commit!(*filters)` to apply buffered calls:
  cover.commit! # => Rails.logger.info('For your information')

  # Access the underlying object if necessary:
  cover.direct.flush

  # Calls can be chained, as they can't
  # have a sensible return value:
  cover.info('line 1').info('line 2')
end
```

By default, when the block closes, `#commit!` is called.
To prevent this behaviour, pass a falsey value as the second argument:

```ruby
Tent.cover(Rails.logger) do |logger|
  logger.info('This will commit')
  logger.commit!
  logger.info('So will this')
end

Tent.cover(Rails.logger, false) do |logger|
  logger.info('This will commit')
  logger.commit!
  logger.info('But this will not')
end
```

The internal buffer is synchonised across threads.

TODO
=====

Nothing outstanding.
