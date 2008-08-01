#--
# Copyright (c) 2008 Matt Lins
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

unless defined? ActiveSupport
  active_support_path = File.dirname(__FILE__) + "/../../activesupport/lib"
  if File.exist?(active_support_path)
    $:.unshift active_support_path
    require 'active_support'
  else
    require 'rubygems'
    gem 'activesupport'
    require 'active_support'
  end
end

require 'active_migration/base'
require 'active_migration/key_mapper'
require 'active_migration/callbacks'
require 'active_migration/dependencies'

ActiveMigration::Base.class_eval do
  include ActiveMigration::KeyMapper
  include ActiveMigration::Callbacks
  include ActiveMigration::Dependencies
end