class AsciiArt
  module Xterm256Color
    # the 6 value iterations in the xterm color cube
    VALUERANGE = [
      0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF
    ]

    # 16 basic colors
    BASIC16 = [
      [ 0x00, 0x00, 0x00 ], # 0
      [ 0xCD, 0x00, 0x00 ], # 1
      [ 0x00, 0xCD, 0x00 ], # 2
      [ 0xCD, 0xCD, 0x00 ], # 3
      [ 0x00, 0x00, 0xEE ], # 4
      [ 0xCD, 0x00, 0xCD ], # 5
      [ 0x00, 0xCD, 0xCD ], # 6
      [ 0xE5, 0xE5, 0xE5 ], # 7
      [ 0x7F, 0x7F, 0x7F ], # 8
      [ 0xFF, 0x00, 0x00 ], # 9
      [ 0x00, 0xFF, 0x00 ], # 10
      [ 0xFF, 0xFF, 0x00 ], # 11
      [ 0x5C, 0x5C, 0xFF ], # 12
      [ 0xFF, 0x00, 0xFF ], # 13
      [ 0x00, 0xFF, 0xFF ], # 14
      [ 0xFF, 0xFF, 0xFF ]  # 15
    ]

    # convert an xterm color value (0-253) to three elements array [r, g, b]
    def self.xterm2rgb(color)
      case color
      when 0..15
        return BASIC16[color].dup

      when 16..232
        color -= 16
        return [VALUERANGE[(color / 36) % 6], VALUERANGE[(color / 6) % 6], VALUERANGE[color % 6]]

      when 233..253
        return [8 + (color - 232) * 0x0a] * 3

      else
        raise ArgumentError, "expected color value in range 0..253 but was #{color}"
      end
    end

    # fill the colortable for use with rgb2xterm
    def self.make_table
      @colortable ||= (0..253).map {|color| xterm2rgb(color) }
    end

    # selects the nearest xterm color for a given [r, g, b] color table
    def self.rgb2xterm(rgb)
      @rgb2xterm_cache ||= {}
      return @rgb2xterm_cache[rgb] ||=
        begin
          self.make_table
          smallest_distance = 1_000_000_000_000
          best_match = 0

          0.upto(253) do |color|
            d = self.euclidean_distance(@colortable[color], rgb)
            if d < smallest_distance
              smallest_distance = d
              best_match = color
            end
          end
          best_match
        end
    end

    # Return euclidean distance between two given vectors v1 and v2.
    # Example:
    #   Xterm256Color.euclidean_distance([0, 0], [1, 1]) # => 1.4142...
    def self.euclidean_distance(v1, v2)
      raise ArgumentError, "Expected two arrays" unless v1.is_a?(Array) && v2.is_a?(Array)
      raise ArgumentError, "Expected two array with the same size (#{v1.size} <=> #{v2.size})" if v1.size != v2.size

      #sum_of_squares = v1.zip(v2).inject(0) {|acc, (a, b)| acc + (a - b) ** 2 }
      sum_of_squares = 0
      v1.size.times do |i|
        sum_of_squares += (v1[i] - v2[i]) * (v1[i] - v2[i])
      end

      return Math.sqrt(sum_of_squares)
    end
  end
end
