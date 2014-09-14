require 'monitor'

# Provides a way of deferring method calls to
# an underlying object.
class Tent
  include MonitorMixin

  # Yields a `Tent` over the given `underlying`.
  # By default, commits to the underlying when
  # the block closes.
  def self.cover(underlying, auto_commit = true, &block)
    new(underlying).tap do |instance|
      yield instance
      instance.commit! if auto_commit
    end
  end

  def initialize(underlying)
    # Maintain a reference to the underlying:
    @underlying = underlying
    # Collect calls for the underlying:
    @buffer = []
    # Allow monitor mixin to initialise:
    super()
  end

  # Provide access to the underlying object.
  def direct
    @underlying
  end

  # Clears the buffer. Optionally, only clears
  # from the buffer.
  def discard!(*filters)
    process_buffer(false, filters)
  end

  # Commits the buffered calls to the underlying.
  def commit!(*filters)
    process_buffer(true, filters)
  end

  private

  # Wrap calls to the underlying.
  class BufferedCall
    attr_reader :name, :args, :block

    def initialize(name, *args, &block)
      @name  = name
      @args  = args
      @block = block
    end

    def apply_to(target)
      block ? target.send(name, *args, &block) : target.send(name, *args)
    end

    def matched_by?(filters)
      0 == filters.length || filters.include?(name)
    end
  end

  # Clear from the buffer elements matching any
  # of the `filters`. Will commit those elements
  # to the underlying if `commit` is true.
  def process_buffer(commit, filters)
    synchronize do
      @buffer.reject! do |call|
        if call.matched_by?(filters)
          call.apply_to(direct) if commit
          true # Remove from buffer
        end
      end
    end
  end

  def method_missing(method, *args, &block)
    return super unless direct.respond_to?(method)

    synchronize do
      @buffer << BufferedCall.new(method, *args, &block)
      self # Make buffering chainable.
    end
  end
end
