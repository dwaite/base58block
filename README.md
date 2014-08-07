# Base58block

Implementation of the Base58 Block algorithm

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'base58block'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install base58block

## Usage

The library itself currently just consists of an encode and decode method.

### Encoding
The encoding is relatively simple. Using a 58 character dictionary
(matching the bitcoin dictionary), we divide the input into 8 byte (64 bit) 
blocks, then convert these to 64 bit integers (in network octet order). This 
block is converted to base58, with each base58 'digit' represented by a
different character in the dictionary. The value is always represented by a
full 11 base58 'digit' number. So for example:

  Base58Block.encode "\0\0\0\0\0\0\0\0" # => "11111111"
  
This is because the zero base58 digit is represented by the character "1" in
the dictionary.

The maximum value 64 bit number is represented in hex as 0xffffffffffffffff

  Base58Block.encode(["FFFFFFFFFFFFFFFF"].pack("H*")) # => "jpXCZedGfVQ"
  
You may need to represent the last bytes in a sequence total less than eight
bytes. This is done rather simply - pad the highest order bytes with zero values
before converting to an integer, convert to base58 per normal, then change the
highest order base58 'digit' to a flag value.

This flag value is `43 + {number of bytes in original block}`. This technique
was chosen because:
1. The highest leading base58 'digit' for a 64 bit unsigned number will be 42,
   so no Base58 value will ever result in the leading digit set to one of the
   flag values
2. The highest leading base58 'digit' for a 56 bit/7 byte unsigned number will
   always be zero, so we will not lose information by assigning an additional
   purpose to the leading digit.

To show an example:

  # Convert the highest seven byte value, 0x00ffffffffffffff
  result = Base58Block.encode(["00FFFFFFFFFFFFFF"].pack("H*")) # => "1Ahg1opVcGW"
  
  # Change first 'digit' to indicate we had only seven bytes input
  result[0] = DICTIONARY[43+7] # => "s"
  
  Base58Block.encode(["FFFFFFFFFFFFFF".pack("H*")]) == result # => true

Note that a partial block still results in 11 characters of output.

###Decoding
Decoding works along the same lines as encoding, so it will likely be useful to
familiarize yourself with encoding before reading the following description.

Given an 11 character block, treat that block as a base58 number. The
individual 'digits' of this number are represented by the character values
within the dictionary. Reverse the dictionary mapping to come up with the
individual digit values of the base58 number. This will allow you to construct
an integer value, which should always be representable with an unsigned 64 bit
value. Then, convert this 64 bit value to network order bytes.

There is a special case when decoding a partial block. If the first 'digit' in
the base 58 value is 43 or higher, this value is a flag indicating a partial
block. Subtracting 43 from this value will give the number of bytes to be output
(1 - 7). 

To convert this value to an integer, you should first set the leading 'digit' to
a zero value. You can then generate an eight byte output as normal. Strip off 
the high order bytes (which will all be zero) to get a value of the desired size.

### Normalization
For the purpose of cryptographic validity, it is useful to have a single source
value represented with a single base58 block encoded value. To this end, the
following additional rules are provided for normalization:

1. Only the last block can be a partial block
2. Partial blocks must indicate between 1 and 7 bytes
3. No additional characters (including whitespace) may appear within the encoded
   value.
# Known issues

- The current decoding algorithm will fail if whitespace or invalid characters
  are in the input value

## Contributing

1. Fork it ( https://github.com/dwaite/base58block/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
