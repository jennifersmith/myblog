---
author: admin
slug: qcon-2011-friday-session-node-js-asynchronous-io-for-fun-and-profit
status: publish
title: ' QCon 2011 - Friday session - Node.js: Asynchronous I/O for Fun and Profit'
categories:
- Software Development
tags:
- qcon
- nodejs
---

Stefan Tilkov started this talk by discussing the difference between
thread and event based I/O. I get the feeling that this might have been
covered in the previous talk (or just old hat to most people) but I
really appreciated the explanation as now I think I finally understand
the difference between the two models. Let's see shall we...

Most commonly used web servers - like Apache, IIS etc. use the thread
based model. Each request is served by a dedicated thread. A request for
a resource might look something like this:

<img src="http://www.websequencediagrams.com/cgi-bin/cdraw?lz=Q2xpZW50LT5TZXJ2ZXIgdGhyZWFkOiBSRVFVRVNUIEdFVCAvbWVudXMvZnJpZGF5IChSZWFkIHJlcXVlc3QpCm5vdGUgb3ZlciAiADYNIjogUGFyc2UgYW5kIHByb2Nlc3MALggKAGANLT5EYXRhYmFzZTogc2VsZWN0ICogZnJvbSAAcwUgd2hlcmUgZGF5ID0gJ0YAgQAFJwBsCwAzCgpEaWcgYXJvdW5kIGluIG15IGluZGV4ZXMgCnRvIGZpbmQgc29tZSBtYXRjaGluZyBkYXRhCmVuZCBub3RlCgB-CACBexFNZW51IHJlY29yZCBmb3IgAH4GAIFeHENhcnJ5IG9uAIFxCGluZwCBZBhGaWxlIHN5c3RlbTogAIJWBSJNZW51cy50ZW1wbGF0ZSIAglcMACMLIjogTG9jYXRlIHRoZSBmaWxlCgBBCwCDQBEAOhwAgykQTW9yZQCBMAsuLi4AgyIQAIQwBjogUkVTUE9OU0UgPGh0bWw-Li4uPC8ABQUKCgoK&amp;s=napkin" alt="image" style="height:504px">

The thread spends much more time sitting around waiting to read/write
data and waiting for data from other collaborators (Database, File
system, Client) than it does actually processing the request. While
waiting for external events to happen, the thread blocks and does not do
much apart from use a lot of memory. The number of threads you are going
to need is going to scale linearly with the amount of concurrent
requests you have (this is correct?), eating memory up and leading to
thread starvation under a high load. The problem will be exacerbated by
an upstream connection experiencing performance problems (like a dodgy
database server): more threads will be hanging around doing nothing
waiting for the upstream service to finish meaning there are less
threads hanging around to serve new requests and thread starvation gets
quicker.

Evented I/O based servers on the other hand will deal with I/O
activities asynchronously and avoid blocking on I/O operations
alltogether. They will make use of events and callbacks to pick up the
processing work again (on whatever thread it happens to be invoked on).
So if in our thread based model a thread blocks while waiting for a
client request to be read from the socket, in the Evented I/O model the
thread will call the corresponding async socket read function, passing
in a callback to be called when the async operation is complete. As it
does not have to wait for the I/O to complete, the calling thread can go
off and do other things - like picking up the next request. Infact, at
the heart of such a server you would probably see an event loop similar
to GUI applications which will just cycle round waiting for incoming
events.

The nginx webserver operates in an evented I/O model and Stefan showed
some interesting comparisons of its performance with Apache
([nginx\_performance](http://blog.webfaction.com/a-little-holiday-present))

The evented I/O model is traditionally regarded as a low level and
complicated pattern. There is support for it in most standard platforms
(.NET IO completion ports and java.nio for example) but it is not widely
used. Thread based is still very much the default.

**JavaScript**

Stefan then went on to talk about everyone's favourite browser scripting
language. Javascript has gone from being reguarded as a 'toy' language
with some strange design features and browser compatibility issues to
one with great framework support, ironing out dom compatibility issues.
With things like the Crockford 'Good Parts' book being widely read, we
as an industry have a good understanding of the language itself - as
well as a good knowledge of the 'bad' parts. All fairly well-covered
stuff but it lead him nicely to:

**Evented I/O + JavaScript =\> Node.js**

So we come on to Node.js - a framework for writing Evented I/O in
JavaScript. Node.js runs on the V8 engine, free from the browser so you
can use it to write performant networking programs - like web servers
etc. As Stefan put it: 'High-performance network runtime, using
JavaScript as a high-level DSL'.

Carrying on with the car based puns, under the hood:

![image\_2](http://dl.dropbox.com/u/18288740/mytw/nodejs.png)
image\_2

Other interesting parts are the low level C libraries:

-   **libev**: event loop library
-   **libeio:**async I/O
-   **c\_ares:**async DNS
-   **http\_parser:**superfast http request/response parser written
    especialy for node.js by its creator [Ryan
    Dahl](https://github.com/ry)

From the code samples, it seems that getting started with basic programs
is pretty easy:

{% highlight javascript %}
var net = require("net");
var server = net.createServer(function (socket) {
  socket.write("Echo server\r\n");
  socket.setEncoding("ascii");;
  socket.on("data", function(data) {
  socket.write(data.toUpperCase());
  });
});
server.listen(8124, "127.0.0.1");
{% endhighlight %}

This listing sets up a server using the net library. When an incoming
socket is accepted, it binds to the data receive event and simply writes
back to the socket the data it receives uppercase. Both I/O parts of
this program - accepting an inbound connection and waiting to receive
data on a socket - are handled asynchronously by passing in event
handlers.

Stefan went through a few more simple code samples which he has put up
on github: [Stefan Tilkov
node-samples](https://github.com/stilkov/node-samples).

**Spaghetti code**

One drawback of working in an asynchronous/callback world is that it
tends to lead to tangled, spaghetti code. If you wanted to call two
operations in a synchrnonous way, it might look like this:


{% highlight javascript %}
jump_to_the_left();
step_to_the_right();
{% endhighlight %}

You can call each method procedurally in the order you desire. In
node.js it might end up looking like this (presuming these were I/O
operations):

{% highlight javascript %}
jump_to_the_left(function(){
    step_to_the_right();
});

{% endhighlight %}

Which presumably if it gets to any kind of complicated, the code would
start to resemble:

{% highlight javascript %}
jump_to_the_left(function(){
   step_to_the_right(function(){
   put_your_hands_on_your_hips(function(){
     	bring_your_knees_in_tight();
    });
  });
 });

{% endhighlight %}

Then if you add in error handling to the mix, synchronously:

{% highlight javascript %}
    try{
      jump_to_the_left();
      step_to_the_right();
    } 
    catch{
       log("Failed to execute timewarp sequence");
    }

{% endhighlight %}

... which wouldn't work asynchronously, as the try/catch would not be
surrounding the point at which the handlers are executed. A convention
has been adopted to pass in the error status as the first parameter to a
callback, leading to:

{% highlight javascript %}
jump_to_the_left(function(err){
  if(err){
    log("Failed to jump to the left");
  }
  step_to_the_right();
});
{% endhighlight %}

It's not hard to see that any program above the level of 'trivial' is
going to get very complex and unreadable.

**Libraries for node**

Fortunately you can mitigate the complexity of working with evented I/O
in node - as well as perform a number of other standard operations -
using the multitude of libraries available for node. See this [list of
node libraries](https://github.com/joyent/node/wiki/modules). These can
be managed using its very own package manager
[npm](https://github.com/isaacs/npm). As node is primarily intended for
web/http server usage, there are many libraries to deal with common
HTTP/web tasks: templates, routing as well as libraries allowing you to
run multiple nodes to explore multiple processors. You can even get an
in-browser debugger:
[node-inspector](https://github.com/dannycoates/node-inspector).

[Step](https://github.com/creationix/step) is a particularly interesting
library that attempts to smooth out some of the dodgy spaghetti code
that arises from working asynchronously.

Stefan also mentioned that alongside all these modules there is also an
active community around node.js. The node.js community are quite chummy
with the NoSQL community too, so apparently you can generally expect
good library support for your NoSQL technology of choice.

**Summary**

In conclusion, Stefan stated that node.js "Popularises the 'right way'
of network programming." and that it is easy to get started with and
also fun to use (profitable too?). In the Q&A, it was interesting to
note that he had more experience using node.js as a client rather than a
server (I don't think we write web servers every day): he might use
node.js to quickly knock up a test client or utility program. I can
really see the value in using node.js this way - as a quick and
productive way of writing networking applications.

This was one of the most enjoyable talks I attended at qcon. Stefan is
an engaging and laidback presenter and I particularly appreciated his
explanation through code samples. I attended the talk to understand more
about node.js (which was just defined in my head as
'javascript-on-the-server-whats-the-point-of-that') and left with a good
understanding and eager to use it when I get a chance.
