=begin
  vim: sw=2:
  Copyright (c) 2012, Gennady Bystritsky <bystr@mac.com>

  Distributed under the MIT Licence.
  This is free software. See 'LICENSE' for details.
  You must read and accept the license prior to use.

  Author: Gennady Bystritsky
=end

require 'ruby-test-helper.rb'
require 'rspec'

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :rspec

  # config.mock_with :flexmock
  # config.mock_with :rr
end

begin
  require 'spec_helper'
rescue LoadError
end
