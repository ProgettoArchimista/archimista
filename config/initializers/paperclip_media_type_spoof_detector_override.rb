# Upgrade 2.0.0 inizio
require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
# Upgrade 2.0.0 fine
