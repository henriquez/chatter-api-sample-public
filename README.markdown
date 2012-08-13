Welcome to the Chatter REST API Sample Application
==================================================

The Salesforce Chatter API sample application is an open source MIT licensed application that illustrates how to use the Chatter REST API to build Chatter UI.  Use cases include integrating a Chatter feed into a 3rd party application or building custom / branded Chatter UI.  [Try it out here](http://chatter-api-sample.herokuapp.com).

Most of the application is written in [CoffeeScript](http://coffeescript.org) for readability and portability. CoffeeScript compiles into fast and readable Javascript that runs in the browser. The primary application file is [chatter.js.coffee](https://github.com/henriquez/chatter-api-sample-public/blob/master/app/assets/javascripts/chatter.js.coffee).  See the [chatter.js file](https://github.com/henriquez/chatter-api-sample-public/blob/master/doc/chatter.js) if you prefer to read Javascript.

Due to Single Origin Policy, all API requests are proxied through the server.  See app/controllers and app/models for how this works.

MIT Open Source License
=======================

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Installation
============

The repo omits a few files for security reasons:

* database.yml
* a sqlite db

You'll have to create these.  See the Rails guides for details.

In addition, there are a several settings that require environment variables to be created.  In config/initializers/secret_token.rb you'll need to configure your site key.  In config/initializers/omniauth.rb you'll see the variables required for your OAuth configuration.  Unless you are inside the salesforce firewall and want to access blitz or GUS, the salesforce provider is the only setting you need and you can delete the others.

As with any Rails installation, you'll have to run "bundle install" to pull in all the dependencies.  See the Rails Guides if you're not familiar with rails setup.

For OAuth to work, your installation must support SSL. There are several ways to do this depending on what type of web server you have. 