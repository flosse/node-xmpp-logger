# node-xmpp-logger

This is a logger for [node-xmpp](https://github.com/astro/node-xmpp).

**note:**

This project is older than the new XMPP extension
"[Event Logging over XMPP (XEP-0337)](http://xmpp.org/extensions/xep-0337.html)"
but upcoming versions (`0.1.x`) will implement [XEP-0337](http://xmpp.org/extensions/xep-0337.html)
with a new API.

[![Build Status](https://secure.travis-ci.org/flosse/node-xmpp-logger.png)](http://travis-ci.org/flosse/node-xmpp-logger)
[![Dependency Status](https://gemnasium.com/flosse/node-xmpp-logger.png)](https://gemnasium.com/flosse/node-xmpp-logger)
[![NPM version](https://badge.fury.io/js/node-xmpp-logger.png)](http://badge.fury.io/js/node-xmpp-logger)

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
### Timestamp

node-xmpp-logger uses [Moment.js](http://momentjs.com/) and you can define your
timestamp format by setting the `timeFormat` property:

```javascript
log.timeFormat = "HH:mm:ss"
```

Possible formats: [Moment docs](http://momentjs.com/docs/#/displaying/format/)
