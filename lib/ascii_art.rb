require File.dirname(__FILE__) + "/ascii_art/xterm256color"
require "RMagick"
require "open-uri"

class AsciiArt
  class Error < StandardError; end
  DEFAULT_GRADIENT = ".:coCO8@"

  attr_accessor :characters_array, :colored

  def initialize(colored)
    @colored = colored
    @characters_array = []
  end

  def colored?
    return @colored
  end

  # Create AsciiArt instance from given image file.
  # Parameters:
  #  image_file_path can be regular path to file or http URL
  #  width - width in characters of created ascii art
  #  gradient - nil or string with gradient characters
  # Example:
  #   ascii_art = AsciiArt.from_image_file("images/image.jpg")
  #   ascii_art.print
  def self.from_image_file(image_file_path, width, colored = true, gradient = nil)
    gradient = DEFAULT_GRADIENT if gradient.nil?
    image = Magick::Image.read(image_file_path).first

    image.change_geometry("#{width}x") do |w, h, img|
      img.resize!(w, h / 2.2, Magick::BoxFilter)
    end
    image = image.sharpen(1.0)
    image = image.contrast(true)

    characters_array = []
    0.upto(image.rows - 1) do |row|
      characters_array << []
      0.upto(image.columns - 1) do |column|
        pixel = image.pixel_color(column, row)
        rgb = [pixel.red, pixel.green, pixel.blue]
        rgb.map! {|value| value >> (Magick::QuantumDepth - 8) }

        char = gradient[pixel.intensity * gradient.size / (Magick::QuantumRange + 1), 1]
        characters_array.last << [char, rgb]
      end
    end

    ascii_art = AsciiArt.new(colored)
    ascii_art.characters_array = characters_array

    return ascii_art
  rescue Magick::ImageMagickError => e
    raise Error.new("Could not read file #{image_file_path} (#{e.message})")
  end

  def to_html
    html = ""
    html << "<pre style=\"background-color: black; font-size: 8px;\">"
    self.characters_array.each do |row|
      row.each do |char, rgb|
        if self.colored?
          html << sprintf("<span style=\"color: rgb(%d, %d, %d)\;\">%s</span>", rgb[0], rgb[1], rgb[2], char)
        else
          html << char
        end
      end
      html << "\n"
    end
    html << "</pre>"

    return html
  end

  def to_text
    text = ""
    self.characters_array.each do |row|
      row.each do |char, rgb|
        if self.colored?
          color = Xterm256Color.rgb2xterm(rgb)
          text << sprintf("\033[38;5;%dm%s\e[0m", color, char)
        else
          text << char
        end
      end
      text << "\n"
    end

    return text
  end
end
