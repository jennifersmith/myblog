---
author: admin
slug: spark-codec-for-openrasta
status: publish
title: Spark codec for OpenRasta
categories:
- Software Development
tags:
- openrasta 
- spark
---

### Update

I haven't really had the chance to support this too much due to various
reasons (new job, laptop with vmware image dying, supreme laziness and
attention span issues). Anyway, the project is now on github and (thanks
to some work from Lee Henson) is the most up to date:
[http://github.com/jennifersmith/openrasta-sparkcodec](http://github.com/jennifersmith/openrasta-sparkcodec)
Hope that helps you all out and thanks for your interest!

* * * * *

It all started after I went to Sebastian Lambla's talk on
[OpenRasta](http://www.ohloh.net/p/openrasta) at a
[VBUG](http://vbug.co.uk/) event. I really got into the framework - it
felt to me as a cleaner and lighter way to think about MVC when compared
to ASP.NET MVC. At the same time, I really wanted to have look at the
[Spark View Engine](http://dev.dejardin.org/) as I think the syntax is a
breath of fresh air and welcome relief from all the tagsoup we seem to
get into when writing MVC views. When I asked 'Is there a Spark codec
for OpenRasta?' I had the reply 'No, but why don't you write one'. Never
one to back down from a challenge I did. And you can download it from
[GoogleCode](http://code.google.com/p/openrastasparkcodec/) (though I
would prefer you grab the trunk cos the latest version is probably
already out of date!). 

###OpenRasta meet Spark, Spark meet OpenRasta 
If you are not familiar with either of these projects, then this project
probably means nothing to you. If you get one and not the other then
read on. 

**OpenRasta** 'is a Resource-Oriented framework to build
MVC-style applications on asp.net 2 and above.' (I copied this from
[here](http://www.ohloh.net/p/openrasta)). Easiest way to get into it I
think is to either hear a talk on it, or use [this
tutorial](http://svn.caffeine-it.com/openrasta/trunk/doc/content/Tutorials/Create-First-Site.html).

The **Spark View Engine** is written for ASP.NET MVC and provides a
slightly alternative syntax for specifying views. Basically it uses an
extended set of attributes and tags on top of plain old HTML to let you
do crazy things like:

{% highlight html %}
  <viewdata products="IEnumerable[[Product]]"/>
  <ul if="products.Any()">
    <li each="var p in products">${p.Name}</li>
  </ul>
  <else>
    <p>No products available</p>
  </else>
{% endhighlight %}

Simple, readable and pretty cool I think, when your alternative is a big
old mess of tagsoup. Out of all the alternatives, it is definitely the
clearest and most logical I have seen so far. Any
web-designers/front-end devs out there want to tell me if they agree? 

### Using the Codec from OpenRasta
In a later post I might choose to
talk about my design approach, but when it came to OpenRasta, this
approach was very much 'Copy what the webforms codec does'. So to use
the spark view engine, you start by adding this to the top of your
configuration block:
{% highlight c# %}
    ResourceSpace.Uses.SparkCodec();
{% endhighlight %}

This does some behind the scenes magic to register all the stuff you
need to use the SparkCodec. Next, for the resources you want to render
using spark, you configure along the lines of:
{% highlight c# %}
ResourceSpace.Uses.SparkCodec();
ResourceSpace.Has.ResourcesOfType()
                    .AtUri("/shoppinglist")
                    .HandledBy()
                    .AndRenderedBySpark("shoppingList.spark"); 

{% endhighlight %}

... note the 'AndRenderedBySpark' extension method there which passes in
the name of the spark template you are going to use. The Spark lookup
procedure takes in a root folder as part of its configuration and I have
defaulted this to 'Views'. So ShoppingList.spark must exist in the
folder views/. There you are - you are all ready to start getting Sparky
with your OpenRasta. Note that OpenRasta allows you to mix and match
your codecs - so you can just have one or two views rendered using Spark
if that is what you want. 

###Extensions to the Spark syntax 
One of the
things I liked about OpenRasta was some of the markup extensions that it
contains. I.e. you can do something like:
{% highlight c# %}
   Xhtml.TextBox(()=>MyResource.Name)
{% endhighlight %}

And through the magic of expressions, the output html is something like:

{% highlight xml %}
<input type="text" name="MyResourceTypeName.Name" value="Whatever the current value of the name is"/>   
{% endhighlight %}

The base view class from which all spark views inherit
(SparkResourceView) exposes the Xhtml interface so you can just use the
extension method as is. However, I thought that seeing as the point of
the Spark syntax is to hook tidily into html, I wanted to provide an
alternative. So I have used the extensions facility in the Spark View
Engine (which was simple once I got the hang of it), to add some custom
attributes. Now if your view contains the following:

{% highlight xml %}
<viewdata resource="Customer"/>
<input for="resource.Name" type="text" anotherattribute="somethingelse"/>
{% endhighlight %}

The output becomes:
{% highlight xml %}
<input name="Customer.Name" value="Fred" type="text" anotherattribute="somethingelse"/>
{% endhighlight %}

Similarly to hook into the URI-resolving stuff in OpenRasta you can have
something like:

{% highlight xml %}
<viewdata resource="Customer">
<a to="resource">Click here to view the customer</a>
<a totype="IEnumerable<Customer>">Click here to view all customers</a>
{% endhighlight %}

On render, this figures out the URIs based on what you set up for the
resources in question as part of the configuration. Anyway, this syntax
is far from complete - it works enough to just about power the demo
application that I packaged with the codec source so I suggest you take
a look at this for more pointers. 

###Futures

 This started as a small
pet project but if you want to give me a hand please please do catch up
with me on [twitter](http://twitter.com/JenniferSmithCo). The same goes
for any other feedback (apart from 'it's crap' - that would not be very
nice). I have a small idea for an application that I wanted to have a go
at with OpenRasta and as I get into implementing this I am sure I will
come up with a few more extensions to the syntax. Now it is far too hot
and I am going out to get an ice lolly.
