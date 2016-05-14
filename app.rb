require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'
require 'docdsl'

register Sinatra::DocDsl

# pull in the models and helpers
Dir.glob('./app/{helpers,models}/*.rb').each { |file| require file }

before { request.path_info.sub! %r{/$}, '' }

# pull in routes
Dir.glob('./app/endpoints/v1/*.rb').each { |file| require file }
