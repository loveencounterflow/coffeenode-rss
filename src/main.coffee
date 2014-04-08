


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

#-----------------------------------------------------------------------------------------------------------
@normalize_tags = ( tags ) ->
  ### Given a list of strings, return a 'typographically' sorted list where
    * all strings are lower-cased,
    * all strings are trimmed of peripheral whitespace,
    * all empty, blank and repeated strings are removed.
  ###
  R         = []
  seen_tags = {}
  for tag in tags
    tag = tag.toLowerCase()
    tag = tag.trim()
    continue if tag is ''
    continue if seen_tags[ tag ]?
    seen_tags[ tag ] = tag
    R.push tag
  R.sort()
  return R

#-----------------------------------------------------------------------------------------------------------
@read = ( request_options, handler ) ->
  Z = []
  #---------------------------------------------------------------------------------------------------------
  mk_request request_options, ( error, response, body ) =>
    return handler error if error?
    return handler new Error "something went wrong" unless response.statusCode is 200
    parser.parseString body, ( error, json ) =>
      return handler error if error?
      # debug json
      # #-----------------------------------------------------------------------------------------------------
      # BAP.walk_containers_crumbs_and_values json, ( error, container, crumbs, value ) =>
      #   return handler error if error?
      #   #...................................................................................................
      #   if crumbs is null
      #     log 'over'
      #     return
      #   #...................................................................................................
      #   locator           = '/' + crumbs.join '/'
      #   # in case you want to mutate values in a container, use:
      #   [ head..., key, ] = crumbs
      #   if TYPES.isa_text value
      #     value = value[ .. 100 ]
      #   else
      #     value = rpr value
      #   log ( TRM.grey "#{locator}:" ), ( TRM.gold value )
      #-----------------------------------------------------------------------------------------------------
      warn json[ 'channel' ].length
      for channel in json[ 'channel' ]
        # debug channel
        Z.push ( entry = [] )
        for item in channel[ 'item' ]
          entry[ 'date_txt' ] = item[ 'pubDate'           ][ 0 ]
          entry[ 'title'    ] = item[ 'title'             ][ 0 ]
          entry[ 'link'     ] = item[ 'link'              ][ 0 ]
          entry[ 'summary'  ] = item[ 'description'       ][ 0 ]
          entry[ 'content'  ] = item[ 'content:encoded'   ][ 0 ]
          entry[ 'tags'     ] = tags = {}
          #.................................................................................................
          for tag in @normalize_tags item[ 'category' ]
            tags[ tag ] = 1
      #-----------------------------------------------------------------------------------------------------
      handler null, Z




