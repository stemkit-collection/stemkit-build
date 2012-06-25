=begin
  vim: sw=2:
  Copyright (c) 2012, Gennady Bystritsky <bystr@mac.com>

  Distributed under the MIT Licence.
  This is free software. See 'LICENSE' for details.
  You must read and accept the license prior to use.

  Author: Gennady Bystritsky
=end

require 'rubygems'

ENV.values_at('ruby.USE_PATH', 'ruby.EXTRA_LOAD_PATH').tap do |_usepath, _extrapath|
  def update_loadpath(items)
    $:.concat items.map { |_item|
      _item.to_s.strip.tap { |_item|
        break nil if _item.empty?
      }
    }.compact
  end

  update_loadpath ENV.to_hash['PATH'].split(File::PATH_SEPARATOR) if _usepath == 'true'
  update_loadpath _extrapath.split if _extrapath
end
