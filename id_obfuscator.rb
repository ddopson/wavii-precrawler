module Wavii
  class IdObfuscationError < ArgumentError; end

  # We want to obfuscate our ids whenever sending them to an end user.
  #
  # Id obfuscation gives us two things:
  #
  # * It helps to avoid the [German tank problem](http://en.wikipedia.org/wiki/German_tank_problem)
  # * It ensures that data we give to a user isn't directly tied to our underlying implementation.
  #
  # This is a port of http://code.activestate.com/recipes/576918/
  class IdObfuscator
    DEFAULT_BLOCK_SIZE = 22
    DEFAULT_MIN_LENGTH = 5
    DEFAULT_ALPHABET   = 'yVSYcPUD5HN9nj7AxWB4JeksvmTCFagRufphM6brXt2wLdKEq8Q3G'

    def initialize(alphabet=DEFAULT_ALPHABET, block_size=DEFAULT_BLOCK_SIZE, min_length=DEFAULT_MIN_LENGTH)
      @alphabet   = alphabet
      @block_size = block_size
      @min_length = min_length

      @alphabet_lookup = {}
      @alphabet.chars.with_index { |c,i| @alphabet_lookup[c] = i }

      @mask    = (1 << @block_size) - 1
      @mapping = Array(0...@block_size).reverse!

      # Because we use this everywhere, and it's short
      @alen = @alphabet.length
    end

    # Obfuscates and encodes an id
    def self.encode_id(id)
      @default_instance ||= self.new
      @default_instance.encode_id(id)
    end

    def encode_id(id)
      unless id.is_a? Integer
        raise "Expected an integer for an id to obfuscate!  Got #{id.inspect}"
      end
      raise "I cannot encode negative numbers: #{id}" if id < 0

      return self.enbase(self.encode(id))
    end

    # Decodes an obfuscated id
    def decode_id(key)
      unless key.is_a? String
        raise "Expected a string for an obfuscated param!  Got #{key.inspect}"
      end

      return self.decode(self.debase(key))
    end

  protected
    # Encodes an integer (as another integer)
    def encode(int)
      masked_int = int & @mask
      result = 0
      @mapping.each_with_index do |b, i|
        result |= (1 << b) if (masked_int & (1 << i)) != 0
      end

      return (int & ~@mask) | result
    end

    # Decodes an integer (as another integer)
    def decode(int)
      masked_int = int & @mask
      result = 0
      @mapping.each_with_index do |b, i|
        result |= (1 << i) if (masked_int & (1 << b)) != 0
      end

      return (int & ~@mask) | result
    end

    # Takes an integer and bases it against our alphabet
    def enbase(int, min_length = nil)
      min_length ||= @min_length
      result = self.inner_enbase(int)

      if min_length > result.length
        return (@alphabet[0] * (min_length - result.length)) + result
      else
        return result
      end
    end

    # Takes a based string and converts it back to an integer
    def debase(val)
      result = 0
      begin
        val.reverse.chars.with_index do |c, i|
          result += @alphabet_lookup[c] * (@alen ** i)
        end
      rescue
        raise IdObfuscationError, "Unable to decode obfuscated id: '#{val}'"
      end

      return result
    end

    def inner_enbase(unit)
      if unit < @alen
        return @alphabet[unit]
      else
        return self.enbase(unit / @alen, 0) + @alphabet[unit % @alen]
      end
    end
  end
end
