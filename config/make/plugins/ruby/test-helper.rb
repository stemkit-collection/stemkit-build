=begin
  vim: sw=2:
  Copyright (c) 2012, Gennady Bystritsky <bystr@mac.com>

  Distributed under the MIT Licence.
  This is free software. See 'LICENSE' for details.
  You must read and accept the license prior to use.

  Author: Gennady Bystritsky
=end

ENV.values_at('ruby.ITEM', 'ruby.LOADED_FROM').tap do |_item, _loadedfrom|
  break unless _item

  ENV['ruby.test.INCLUDED'].to_s.split.tap do |_included|
    if _included.empty?
      ENV['ruby.test.EXCLUDED'].to_s.split.tap do |_excluded|
        exit 0 if _excluded.any? { |_pattern|
          File.fnmatch? _pattern, _item
        }
      end
    else
      exit 0 unless _included.any? { |_pattern|
        File.fnmatch? _pattern, _item
      }
    end
  end

  puts "= #{_item}"
  $" << File.join(_loadedfrom, _item) if _loadedfrom
end

require 'ruby/exec-helper.rb'

begin
  require 'ruby/project-test-helper.rb'
rescue LoadError
end
