#!/usr/bin/env ruby1.9

# Copyright 2013 Christopher Alfeld
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Oghma Server
#
# This is a complete server for Oghma.
#
# Author:: Christopher Alfeld (calfeld@calfeld.net)

require 'rubygems'
require 'sinatra'

HOME = File.dirname(__FILE__)
$:.unshift(File.join(HOME, 'server/heron'))

require 'sinatra_comet'
require 'sinatra_dictionary'

# Initialize Dictionary Database
DICTIONARY_DB = File.join(HOME, 'oghma.db')

Thread.abort_on_exception = true

class OghmaServer < Sinatra::Base
  set :public_folder, File.join(HOME, 'public')
  enable :static
  enable :threaded
  enable :run
  enable :dump_errors
  enable :logging
  use Rack::CommonLogger

  # Defines
  # /comet/connect
  # /comet/disconnect
  # /comet/receive
  # /comet/flush
  include ::Heron::SinatraComet

  # Path to dictionary; used by SinatraDictionary.
  DICTIONARY_DB_PATH = DICTIONARY_DB
  # Defines
  # /dictionary/subscribe
  # /dictionary/messages
  include ::Heron::SinatraDictionary

  dictionary.on_verbose   = -> s     { puts "DICT #{s}"                   }
  dictionary.on_error     = -> s     { puts "DICT ERROR #{s}"             }
  dictionary.on_subscribe = -> id, s { puts "DICT SUBSCRIBE [#{id}] #{s}" }
  dictionary.on_collision = -> s     { puts "DICT COLLISION #{s}"         }

  comet.enable_debug

  comet.on_connect    = -> client_id { puts "COMET CONNECT #{client_id}"    }
  comet.on_disconnect = -> client_id { puts "COMET DISCONNECT #{client_id}" }

  get '/' do
    redirect '/index.html'
  end

  at_exit { dictionary.shutdown }

  run!
end

# Work around Sinatra bug.
exit
