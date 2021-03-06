###
Copyright (c) 2013, Markus Kohlhase <mail@markus-kohlhase.de>
###

util   = require "util"
ltx    = require "ltx"
moment = require "moment"

NONE  = 0
DEBUG = 1
LOG   = 2
INFO  = 3
WARN  = 4
ERROR = 5
FATAL = 6

class Logger

  constructor: (@xmpp, opt={}) ->
    unless typeof @xmpp is "object"        and
           typeof @xmpp.send is "function" and
           @xmpp.connection?.jid?
      throw new Error "invalid xmpp object"

    @xmpp.on "stanza", @_onStanza
    { @timeFormat, @recipients } = opt
    @recipients ?= {}

  @levels = { NONE, DEBUG, LOG, INFO, WARN, ERROR, FATAL }

  _getLevelName: (l) -> return k for k,v of Logger.levels when l is v

  _emit: (level, args) ->
    msg = "#{moment().format(@timeFormat)},#{@_getLevelName level}: "
    msg += (util.inspect a for a in args when a?).join(' ')
    body = new ltx.Element("body").t(msg)
    for jid,v of @recipients
      if NONE < v.level <= level
        message = new ltx.Element("message",
          to: jid, from: @xmpp.connection.jid).cnode(body)
        @xmpp.send message

  _sendPresence: (jid, type) ->
    @xmpp.send new ltx.Element "presence",
      to: jid
      from: @xmpp.connection.jid
      type: type

  _onStanza: (s) =>
    return unless s?
    me   = @xmpp.connection.jid
    from = s.attrs.from
    from = from.split('/')[0] if from?.indexOf('/') > -1

    if from? and @recipients[from]?
      switch s.name
        when "presence"
          switch s.attrs.type
            when "subscribed"
              @recipients[from].subscribed = true
            when "subscribe"
              @_sendPresence from, "subscribed"

  debug: -> @_emit DEBUG, arguments
  log:   -> @_emit LOG,   arguments
  info:  -> @_emit INFO,  arguments
  warn:  -> @_emit WARN,  arguments
  error: -> @_emit ERROR, arguments
  fatal: -> @_emit FATAL, arguments

  register: (jid) ->
    throw new Error unless typeof jid is "string" and jid.length > 0
    @recipients[jid] ?= {level: DEBUG}

  sendInvite: (jid) ->
    throw new Error "JID was not registeres" unless @recipients[jid]?
    @_sendPresence jid, "subscribe"

  sendPresence: -> @_sendPresence jid for jid,v of @recipients

  setLogLevel: (jid, level=DEBUG) ->
    throw new Error "JID was not registeres" unless @recipients[jid]?
    if typeof level is "string"
      level = Logger.levels[level.toUpperCase()]
    if typeof level isnt "number" or not (NONE <= level <= FATAL)
      throw new Error "invalid log level"
    @recipients[jid].level = level

module.exports = Logger
