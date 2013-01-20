global.buster = require "buster"
global.sinon  = require "sinon"
buster.spec.expose()

describe "The Logger", ->

  Logger = require "../src/Logger"

  before ->
    @log = new Logger { jid: "foo", send: (->), on:(->) }

  it "is class", ->
    (expect typeof Logger).toBe "function"
    (expect -> new Logger).toThrow()
    (expect -> new Logger {}).toThrow()
    (expect -> new Logger {jid: "x", on: (->), send: ->}).not.toThrow()

  it "provides loggin common methods", ->
    (expect typeof @log.info).toBe "function"
    (expect typeof @log.debug).toBe "function"
    (expect typeof @log.warn).toBe "function"
    (expect typeof @log.error).toBe "function"
    (expect typeof @log.fatal).toBe "function"

  it "provides a method to register a JID", ->
    (expect typeof @log.register).toBe "function"
    (expect => @log.register()).toThrow()
    (expect => @log.register("x@y")).not.toThrow()

  it "has an object of recipients", ->
    @log.register("x@y.z")
    (expect typeof @log.recipients["x@y.z"]).toBe "object"

  it "provides a method to send invites to a JID", (done) ->
    log = new Logger
      jid: "foo"
      on: (->)
      send: (data) ->
        (expect data.tree()).toEqual '<presence to="foo@bar.z" from="foo" type="subscribe"/>'
        done()
    (expect typeof log.sendInvite).toBe "function"
    (expect -> log.sendInvite "foo@bar").toThrow()
    log.register("foo@bar.z")
    log.sendInvite "foo@bar.z"

  it "has provieds the log level constants", ->
    (expect Logger.levels.NONE).toBe  0
    (expect Logger.levels.DEBUG).toBe 1
    (expect Logger.levels.LOG).toBe   2
    (expect Logger.levels.INFO).toBe  3
    (expect Logger.levels.WARN).toBe  4
    (expect Logger.levels.ERROR).toBe 5
    (expect Logger.levels.FATAL).toBe 6

  it "provides a method to set the log level for a JID", ->
    (expect typeof @log.setLogLevel).toBe "function"
    @log.register("x@y.z")
    (expect => @log.setLogLevel "x@y.z", -1).toThrow()
    (expect => @log.setLogLevel "x@y.z", 7).toThrow()
    (expect => @log.setLogLevel "x@y.z", 3).not.toThrow()
    (expect => @log.setLogLevel "x@y.z", "foo").toThrow()
    (expect => @log.setLogLevel "x@y.z", "fatal").not.toThrow()
    (expect => @log.setLogLevel "not@register.ed", "fatal").toThrow()

  it "sends all log levels through chat by default", (done) ->
    log = new Logger
      jid: "foo"
      on: (->)
      send: (data) ->
        (expect data.tree().name).toEqual 'message'
        (expect data.tree().getChild("body").text().split("DEBUG")[1]).toEqual ': foo'
        done()
    log.register("foo@bar.z")
    log.debug "foo"

  it "filters logs by the current level", (done) ->
    log = new Logger
      jid: "foo"
      on: (->)
      send: (data) ->
        (expect data.tree().getChild("body").text().split("ERROR")[1]).toEqual ': ooh'
        done()
    log.register("foo@bar.z")
    log.setLogLevel("foo@bar.z", "warn")
    log.debug "silent"
    log.error "ooh"
