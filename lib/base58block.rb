require "base58block/version"

module Base58Block
  DICTIONARY = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  REVERSE    = [
      0,   1,   2,   3,   4,   5,   6,   7,   8, nil, nil, nil, nil, 
    nil, nil, nil,   9,  10,  11,  12,  13,  14,  15,  16, nil,  17, 
     18,  19,  20,  21, nil,  22,  23,  24,  25,  26,  27,  28,  29,
     30,  31,  32, nil, nil, nil, nil, nil, nil,  33,  34,  35,  36,
     37,  38,  39,  40,  41,  42,  43, nil,  44,  45,  46,  47,  48,
     49,  50,  51,  52,  53,  54,  55,  56,  57 ]
  REVERSE_START = 49

  private
  def self.reverse_dictionary c
    idx = c.bytes.first
    if idx < REVERSE_START
      nil
    else
      REVERSE[ idx - REVERSE_START]
    end
  end

  public
  def self.encode data
    data = data.dup
    result = ""
    
    # operate on blocks of 8 bytes. The last block may less than 8 bytes
    data.each_byte.each_slice(8) do |block|
      encoded_block = ""
      count = block.length

      #convert input block into an integer using network order
      total = block.inject {|sum, n| sum * 256 + n }

      # repeatedly mod/divide 
      while total > 0 do
        total, index = total.divmod 58
        encoded_block << DICTIONARY[index]
      end

      # if output is less than 11 characters, pad with "1"
      padding = 11 - encoded_block.bytesize
      encoded_block << "1" * padding
      
      # indicate less than eight bytes by changing the high order character
      # (which is always '1' if you have less than eight bytes input) to
      # a value which cannot occur
      if count < 8
        encoded_block[10] = DICTIONARY[43+count]
      end
      
      # We want the data to be in network order, so we reverse it now
      encoded_block = encoded_block.reverse
      result << encoded_block
    end
    result
  end

  def self.decode text
    text = text.dup
    result = "".force_encoding "binary"
  
    # operate on blocks of 8 bytes. The last block may less than 8 bytes
    text.each_char.each_slice(11) do |block|
      
      # create an array of the individual base 58 'digits'
      decoded_block = block.map{|c| reverse_dictionary c }
      if decoded_block.include? nil
        return nil
      end

      # decode the byte count, stripping off the flag if needed
      byte_count = 8
      if decoded_block[0] >= 43
        byte_count = c[0] - 43
        decoded_block = decoded_block[1..-1]
      end

      # convert to integer value
      integer = decoded_block.inject{|sum, i| sum * 58 + i }

      # convert integer to 8 byte array (in reverse order)
      data = []
      8.times do
        integer, mod = integer.divmod 256
        data << mod
      end
      # strip off the leading zero bytes if we are a different byte count
      data = data[0...byte_count].reverse

      # pack bytes to a (binary) string and append to result
      result << data.pack("C*")
    end
    result
  end
end
