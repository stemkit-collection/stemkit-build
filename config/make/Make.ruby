# vim: ft=make: sw=2:

${call core.show-current-location}

# The weird series of -e options is needed here because make adds option -c
# to execute the command line, causing ruby syntax errors. So here we simply
# force numeric variable 'c' by assigning 0. '-c' after the last -e will
# make a legal expression, while the actual parameter evaluation is done
# by the second -e.
#

ifndef SPECDIR
SPECDIR = SPECS specs
endif

loadpath := ${strip $(LOADPATH)}
ifdef loadpath
  loadpath := $(loadpath):$(PATH)
else
  loadpath := $(PATH)
endif

export RUBY_EXTRA_LOADPATH := $(loadpath)

RUBY = ruby -rubygems
JRUBY = jruby -rubygems -rjava

SHELL = $(RUBY) -r fileutils -e 'c=0' -e 'eval ARGV.first' -e

# Here we have to resort to another "trick" to compensate for "slight" JRuby
# incompatibility. When -I ${PATH}, load("spec") used inside RSpec launcher
# script (also named "spec"), tries to load the laucher script again instead
# of loading the gem (as intended). This causes looping in load, eventually
# crashing eihter on "Stack level too deep", or "Too many open files".
#
# Solution: invoke_spec() takes care of adding extra loadpath info, path
# components that have a file named like RSpec launcher script are not
# included.
#
define invoke_spec
  rspec_launcher = 'spec';
  path = ENV['RUBY_EXTRA_LOADPATH'].split(':').reject { |_path|
    _path.strip.empty? or File.exist?(File.join(_path, rspec_launcher));
  };
  $$:.concat path;
  require 'sk/file-locator';
  %w[$(SPECDIR)].map { |_item| Dir.glob(_item) }.flatten.each do |_folder|
    File.directory? _folder and begin
      system %Q[ $(1) -I#{path.join(':')} -I#{_folder} -S #{rspec_launcher}
        --require sk/spec/config $(2)
        #{SK::FileLocator.new(_folder).find_bottom_up('*[_-]spec.rb').join(' ')}
      ] or exit 2
    end
  end
endef

all::
	@ puts "Use 'make [j]test[s]' or 'make [j]spec[s]' for unit tests or specs ('j' for JRuby)."

test spec jtest jspec::
	@ %w[ $(ITEMS) ].empty? && Dir['*/makefile'].map { |item| system "make -C #{File.dirname(item)} $(@)" or exit(2) }

test:: test-local
jtest:: jtest-local

spec:: spec-local
jspec:: jspec-local

tests:: test
jtests:: jtest
specs:: spec
jspecs:: jspec

tests-local local-test local-tests:: test-local
specs-local local-spec local-specs:: spec-local
jtests-local local-jtest local-jtests:: jtest-local
jspecs-local local-jspec local-jspecs:: jspec-local

test-local::
	@ items = %w[ $(ITEMS) ]; Dir['*.rb'].each { |item| next if items.empty? == false && items.include?(item) == false; system "$(RUBY) -I$(RUBY_EXTRA_LOADPATH) #{item}" or exit(2) }

jtest-local::
	@ items = %w[ $(ITEMS) ]; Dir['*.rb'].each { |item| next if items.empty? == false && items.include?(item) == false; system %Q[ $(JRUBY) -e '$$:.concat ENV["RUBY_EXTRA_LOADPATH"].split(":"); $$:.delete("."); $$:.delete(""); file = #{File.expand_path(item).inspect}; $$0.replace file; load file'] or exit(2) }

spec-local::
	@ ${strip ${call invoke_spec, $(RUBY), --color -fs}}

test-local::
	@ ${strip ${call invoke_spec, $(RUBY)}}

jspec-local::
	@ ${strip ${call invoke_spec, $(JRUBY), --color -fs}}

jtest-local::
	@ ${strip ${call invoke_spec, $(JRUBY)}}
