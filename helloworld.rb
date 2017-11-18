require 'sinatra'
require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'securerandom'
require_relative 'mongo_helper.rb'

get '/' do
  "Hello World!"
end