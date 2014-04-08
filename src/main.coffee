


# require './feed.rss.json'

############################################################################################################
njs_fs                    = require 'fs'
# njs_path                  = require 'path-extra'
#...........................................................................................................
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'rss'
log                       = TRM.get_logger 'plain',   badge
info                      = TRM.get_logger 'info',    badge
whisper                   = TRM.get_logger 'whisper', badge
alert                     = TRM.get_logger 'alert',   badge
debug                     = TRM.get_logger 'debug',   badge
warn                      = TRM.get_logger 'warn',    badge
help                      = TRM.get_logger 'help',    badge
echo                      = TRM.echo.bind TRM
BAP                       = require 'coffeenode-bitsnpieces'
mk_request                = require 'request'
XML2JS                    = require 'xml2js'
#...........................................................................................................
parser_options            =
  trim:                     yes
  explicitRoot:             no
  explicitArray:            yes
parser                    = new XML2JS.Parser parser_options

options =
  url:      'https://gueltiger-gutschein.de/tag/vodafone,berlin/feed'


f = ->
  #---------------------------------------------------------------------------------------------------------
  mk_request options, ( error, response, body ) ->
    throw error if error?
    throw new Error "something went wrong" unless response.statusCode is 200
    parser.parseString body, ( error, json ) =>
      throw error if error?
      # debug json
      #-----------------------------------------------------------------------------------------------------
      BAP.walk_containers_crumbs_and_values json, ( error, container, crumbs, value ) =>
        throw error if error?
        #...................................................................................................
        if crumbs is null
          log 'over'
          return
        #...................................................................................................
        locator           = '/' + crumbs.join '/'
        # in case you want to mutate values in a container, use:
        [ head..., key, ] = crumbs
        if TYPES.isa_text value
          value = value[ .. 100 ]
        else
          value = rpr value
        log ( TRM.grey "#{locator}:" ), ( TRM.gold value )
      #-----------------------------------------------------------------------------------------------------
      for channel in json[ 'channel' ]
        # debug channel
        for item in channel[ 'item' ]
          date_txt    = item[ 'pubDate'           ][ 0 ]
          title       = item[ 'title'             ][ 0 ]
          link        = item[ 'link'              ][ 0 ]
          summary     = item[ 'description'       ][ 0 ]
          content     = item[ 'content:encoded'   ][ 0 ]
          tags        = item[ 'category'          ]
          debug 'date_txt:    ', date_txt
          debug 'title:       ', title
          debug 'link:        ', link
          debug 'summary:     ', summary
          debug 'content:     ', content
          debug 'tags:        ', tags



f()


