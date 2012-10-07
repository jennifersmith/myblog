---
layout: post
title: "You write it, you support it"
date: 2012-10-06 16:56
comments: true
categories: 
- software development
published: false
tags : devops, appdev
---

I have spent the last few months working in our 'devops' team *. I
have learnt a great deal of new things - and it has been really
enjoyable thanks in no small part to the patience of my team mates in
helping me understand unfamiliar concepts (like DNS - wow that's a doozy).

(\* I use inverted commas here as I don't think 'devops' is a great
name for a team)

I have moved from writing new features to having to support these
features in production. If something goes wrong, it's
our team that has to stabilise it, fix the issue and
then figure out how we could have avoided it in the first place. As a team, a significant proportion of our time is
spent on support and firefighting tasks.

There are common problems that crop up in the applications and pieces of
applications that we are being asked to support:

* *Too much logging:* Filling up the log files with unhelpful and
   excessive messages. This causes problems in terms of log file
   storage requirements and making a very high signal to noise
   ratio when trying to localise error messages.

* *Too little logging:* Insufficient logging for offline
   jobs, swallowing exceptions without logging them. This makes fault
   localisation rather tough.

* *Explicitly dealing with failure:* Applications that fail to deal
   with [Murphy's Law](http://en.wikipedia.org/wiki/Murphy's_law):
   upstream services that go down/slow down, dodgy input from
   users/downstream services, unavailability of files/network
   resources. This may cause the application to fail in surprising
   ways: blocking threads, eating up memory and yet more logging. In
   worse cases, this might cause security vulnerabilities.
   
* *Lack of switches:* Assuming we cannot enumerate
   all the problems that can occur in production, we need to be able
   to switch off or degrade features at run time. We use feature toggles for hiding features for
   releasing, but we don't tend to build these for feature degradation
   in mind. As a result, this means that we end up having to fix
   things quickly and apply ad hoc rather than planned mitigation techniques.

* *Hard-coding configuration:* Configuration changes that are baked
   into the code repository and require rebuilding of deployment
   artefacts or "all or nothing" configuration. To alter a
   configuration parameter (perhaps to temporarily mitigate a problem)
   we need to rebuild and redeploy the system.
   
* *Lack of metrics and monitoring:* When all these things go wrong,
   how do we know? We often tend to find that we need to add metrics
   and monitoring after the feature has been deployed into production.

So how do we fix these problems? How do we make sure that the
operational characteristics of our application are given sufficient consideration?

One way would be to educate the developers. Compile lists of common
errors, checklists of "Have you considered?" style questions. We could
raise bugs, and get work prioritised to fix holes in the metrics,
monitoring.

That is addressing the symptoms, but not the underlying cause. I
believe that the underlying cause is: **the people responsible for
writing the software are not responsible for it's time in production**.

Right now our feedback loops look a little like this:

![Broken feedback loops](/images/broken_feedback_loop.jpg)

Developers release code to production. When something goes wrong, a
different team is responsible for firefighting and as a result they
raise issues and feature requests back to the developer team. 

This is sub-optimal in several ways. The developers are more or less
oblivious to the harm caused by the issues I listed above. My team are
the ones trawling log files, piecing together events, staring at
graphs till our eyes water. We can tell them as many times to fix
these issues but until they actually see the problems we do, this work
will never be incorporated into building the feature in the first
place.

I believe a more optimal solution is "You write it, you support
it". Supporting the code you write in a production setting is an
incredibly valuable way of helping you learn how to write production
supportable code!

Being exposed to the pain of bad log messages, hard-coded
configuration means that you are far less likely to make the same
mistakes later on. This leads to more supportable production systems and
eventually less downtime. I do not think having this feedback
filtering through a third party (aka the devops team) is conducive to
effective learning.

### Aren't developers supposed to be developing?

So a common counter to making developers responsible for production is
that they are supposed to be writing the code not supporting it! If
they spend all their time supporting code in production then they will
get less features into the product, velocity targets etc. etc.

This argument presupposes two things: One, that support will take
up a significant amount of their time; two, that writing new features
is more important than supporting existing features.

A sensible and empowered development team should be able to work out
ways to reduce the time spent in support both for existing and new
features - not only improving developer productivity but also reducing
the likelihood of significant user-facing outage. Prioritising new features over supporting existing features
is a decision that works in the short term, but as a system grows and
users begin to rely on it, _existing, working features are far more important
than new, unproven features_!

### What about the devops team?

Have I taken away part of this team's job? Well not really. In the
last few months that I have spent as part of this team I have noticed
that this firefighting detracts a great deal from our actual
work. It's actually pretty difficult too as we are trying to support
code and features that we didn't write. Raising bugs and communicating
the work that needs to be done to the developer team also takes a long time.

Just like the application teams, we have features and systems
that we are developing and looking after. Instead of web sites and
services, we look after servers, provisioning, load balancers,
replication. In fact when it comes down to it, we are just another
team responsible for a set of components.


Does that mean the devops team should stop firefighting all together?
Probably not. Individuals in our teams have a great deal of experience
and many tools and techniques up their sleeves for fault localisation,
mitigation and so on (even if it is just being handy with
netcat!). Losing that would be silly.

The role of the devops team when it comes to application support
should that of guidance, support and collaboration with the
application developers. I believe that is really what 'devops' means after all.

![Perfect harmony](/images/perfect_harmony.jpg)

