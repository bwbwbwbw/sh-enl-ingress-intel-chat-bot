GLOBAL.ROOT_DIR = __dirname + '/..'
GLOBAL.APP_DIR = ROOT_DIR + '/build'
GLOBAL.LIB_DIR = APP_DIR + '/lib'
GLOBAL.PLUGINS_DIR = APP_DIR + '/plugins'

logger = GLOBAL.logger = require 'winston'
logger.exitOnError = false
logger.remove logger.transports.Console
logger.add logger.transports.Console,
    colorize:   true
    timestamp:  true
logger.add logger.transports.File,
    filename:   ROOT_DIR + '/bot.log'

noop = GLOBAL.noop = ->
    null

require APP_DIR + '/config.js'
require LIB_DIR + '/bot.js'
require LIB_DIR + '/leaflet.js'
require LIB_DIR + '/utils.js'
require LIB_DIR + '/database.js'
require LIB_DIR + '/mungedetector.js'
require LIB_DIR + '/accountinfo.js'
require LIB_DIR + '/public.js'
require LIB_DIR + '/faction.js'

async = require 'async'

async.series [

    (callback) ->

        # raise error here
        logger.info '[MungeDetector] Detecting munge set...'
        MungeDetector.detect callback

    , (callback) ->
        
        # raise error here
        AccountInfo.fetch callback

    , (callback) ->

        PublicListener.init callback
    
    , (callback) ->

        FactionListener.init callback

    , (callback) ->

        logger.info '[Bot] started'
        MungeDetector.start()
        PublicListener.start()
        FactionListener.start()
        callback()

], (err) ->

    Database.db.close() if err