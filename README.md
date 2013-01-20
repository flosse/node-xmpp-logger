# node-xmpp-logger

Logger for [node-xmpp](https://github.com/astro/node-xmpp).

[![Build Status](https://secure.travis-ci.org/flosse/node-xmpp-logger.png)](http://travis-ci.org/flosse/node-xmpp-logger)

## Install

    npm install node-xmpp-logger

## Usage

```javascript
var xmpp   = require("node-xmpp");
var Logger = require("node-xmpp-logger");

// create an xmpp object
var component = new xmpp.Component({
  jid      : "mycomponent",
  password : "secret",
  host     : "127.0.0.1",
  port     : "8888"
});

// create new instance
var log = new Logger(xmpp);

// add an recipient
log.register("myLoggerBot@service.tld");

// allow him to add you to his roster
log.sendInvites("myLoggerBot@service.tld");

// set the log level
log.setLogLevel("myLoggerBot@service.tld", "warn");

log.debug("First log");
log.info("Hello world!");
log.warn("The server is quite busy");
log.error("Something went wrong");
log.fatal("OMG!");
```
