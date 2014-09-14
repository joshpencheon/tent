require 'minitest/autorun'
require 'tent'

class TestTent < Minitest::Test

  describe 'Tent' do
    before do
      @item = [1,2,3]
      @tent = Tent.new(@item)
    end

    describe '#direct' do
      it 'should return the underlying object' do
        assert_equal @item, @tent.direct
      end
    end

    describe 'when called with unknown methods' do
      describe 'for the underlying' do
        it 'should buffer the calls' do
          @tent.push(4).reverse.push(5)
          assert_equal 3, @tent.instance_eval { @buffer.length }
        end
      end

      describe 'that the underlying will not have' do
        it 'should raise an exception' do
          assert_raises(NoMethodError) { @tent.foobar(1) }
        end
      end
    end

    describe 'with items in the buffer' do
      before do
        @tent.push(4)
        @tent << 5
        @tent.push(6)
        @tent.reject! { |x| x % 2 == 0 }
        @tent.reverse!
      end

      it 'should not affect the underlying' do
        assert_equal [1,2,3], @item
      end

      describe '#commit!' do
        describe 'without arguments' do
          before do
            @tent.commit!
          end

          it 'should apply the calls in order' do
            assert_equal [5,3,1], @item
          end

          it 'should empty the buffer' do
            assert_equal 0, @tent.instance_eval { @buffer.length }
          end
        end

        describe 'with arguments' do
          before do
            @tent.commit!(:push, :reverse!)
          end

          it 'should apply the filtered calls in order' do
            assert_equal [6,4,3,2,1], @item
          end

          it 'should filter the buffer' do
            buffer = @tent.instance_eval { @buffer }
            assert_equal 2, buffer.length
            assert buffer.detect { |call| :<< == call.name }
            assert buffer.detect { |call| :reject! == call.name }
          end
        end
      end

      describe '#discard!' do
        describe 'without arguments' do
          before do
            @tent.discard!
          end

          it 'should not apply the calls' do
            assert_equal [1,2,3], @item
          end

          it 'should empty the buffer' do
            assert_equal 0, @tent.instance_eval { @buffer.length }
          end
        end

        describe 'with arguments' do
          before do
            @tent.discard!(:push, :reverse!)
          end

          it 'should not apply the filtered calls' do
            assert_equal [1,2,3], @item
          end

          it 'should filter the buffer' do
            buffer = @tent.instance_eval { @buffer }
            assert_equal 2, buffer.length
            assert buffer.detect { |call| :<< == call.name }
            assert buffer.detect { |call| :reject! == call.name }
          end
        end
      end
    end

    describe '::cover' do
      it 'should yield a Tent' do
        value = nil
        Tent.cover([]) { |object| value = object }
        assert value.is_a?(Tent)
      end

      it 'should return a Tent' do
        value = Tent.cover([]) {  }
        assert value.is_a?(Tent)
      end

      it 'should auto-commit by default' do
        Tent.cover(@item) { |i| i.push(4) }
        assert_equal [1,2,3,4], @item
      end

      it 'should not auto-commit with second argument' do
        Tent.cover(@item, false) { |i| i.push(4) }
        assert_equal [1,2,3], @item

        Tent.cover(@item, false) { |i| i.push(4); i.commit! }
        assert_equal [1,2,3,4], @item
      end
    end
  end

end
