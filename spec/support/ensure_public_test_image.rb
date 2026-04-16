# frozen_string_literal: true

require 'fileutils'

# 1x1 PNG（教材の public/images/test_image.png が無い環境用）
MINIMAL_1X1_PNG_HEX =
  '89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c489' \
  '0000000a49444154789c63000100000500010d0a2db40000000049454e44ae426082'

RSpec.configure do |config|
  config.before(:suite) do
    path = Rails.root.join('public/images/test_image.png')
    FileUtils.mkdir_p(path.dirname)
    next if path.file?

    File.binwrite(path, [MINIMAL_1X1_PNG_HEX].pack('H*'))
  end
end
