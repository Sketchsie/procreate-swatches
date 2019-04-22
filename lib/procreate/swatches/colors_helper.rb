# frozen_string_literal: true

module Procreate
  module Swatches
    module ColorsHelper
      # +.swatches+ files can hold a maximum of 30 colors.
      SWATCHES_MAX_SIZE = 30
      SWATCHES_ALPHA = 1
      SWATCHES_COLOR_SPACE = 0
      SELECTED_KEYS = %w[hue saturation brightness].freeze

      # Transforms the {Chroma} color be exported to the +.swatches+ file.
      #
      # @param [Chroma::Color] color Color
      #
      # @return [Hash{hue => Float, saturation => Float, brightness => Float, alpha => Integer, colorSpace => Integer}]
      #
      def to_swatches_json(color)
        hsv_color = color.hsv

        hue = hsv_color.h / 360
        saturation = hsv_color.s
        brightness = hsv_color.v

        to_color_json(hue, saturation, brightness)
      end

      #
      # Transforms the HSV (HSB) parameters into
      # a hash, to be exported to the +.swatches+ file.
      #
      # @param [Float, Integer] hue Hue
      # @param [Float, Integer] saturation Saturation
      # @param [Float, Integer] brightness Brightness/Value
      #
      # @return [Hash{hue => Float, saturation => Float, brightness => Float, alpha => Integer, colorSpace => Integer}]
      #
      def to_color_json(hue, saturation, brightness)
        {
          hue: hue,
          saturation: saturation,
          brightness: brightness,
          alpha: SWATCHES_ALPHA,
          colorSpace: SWATCHES_COLOR_SPACE
        }
      end

      #
      # Generates a string formatted to initialize a {Chroma::Color} from HSV values
      #
      # @param [Hash{hue => Float, saturation => Float, brightness => Float}] color Color as hash (from parsed +.swatches+ file)
      #
      # @return [String] string String formatted to initialize a {Chroma::Color} from HSV values
      #
      def to_chroma_hsv(color)
        hue, saturation, brightness = *color.values_at(*SELECTED_KEYS)
        hue, saturation, brightness = *[hue * 360, saturation * 100, brightness * 100].map(&:round)

        +"hsv(#{hue}, #{saturation}%, #{brightness}%)"
      end

      #
      # Checks a "color" before adding it to a {Procreate::Swatches::Wrapper} instance's colors array.
      #
      # @param [Chroma::Color, String] color A string or a {Chroma::Color}
      #
      # @return [Chroma::Color] Return a {Chroma::Color} if the color is already an instance of {Chroma::Color}, or the string can be converted to one.
      # @return [nil] Returns nil when {Chroma::Color} can't build a color object from the provided string
      #
      def prepare_color_for_push(color)
        return color if color.is_a?(Chroma::Color)

        begin
          Chroma::Color.new(color.dup)
        rescue Chroma::Errors::UnrecognizedColor
          nil
        end
      end
    end
  end
end
