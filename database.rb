$:.unshift File.dirname(__FILE__)
require 'mongoid'
require 'model'

Mongoid.load!("../mongoid.yml", :development)
