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

# pull in routes
Dir.glob('./app/controllers/v1/*.rb').each { |file| require file }
