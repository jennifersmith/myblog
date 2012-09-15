---
author: admin
slug: static-methods-feel-the-fear-and-do-it-anyway
status: publish
title: 'Static methods: feel the fear and do it anyway'
categories:
- Software Development
tags:
- design
- c#
- refactoring
---

When your tests go green, it's often a good idea to think about tidying
up the internals of the method you just added/changed. One of my
favourite things to do here is to extract out meaningful methods from
the implementation e.g

{% highlight csharp %}
if(toolkit.Contains(Tools.Hammer))
{
    var hammer = toolkit[x.Tool.Hammer];
    Day.Morning.Do(hammer.Execute);
    Day.Evening.Do(hammer.Execute);
    ThisLand.AllOver.Do(hammer.Execute);
}
{% endhighlight %}

... At the click of an alt-shift-m becomes :
i
{% highlight csharp %}
if(IHadAHammer())
{
    IdHammerInThe(Day.Morning);
    IdHammerInThe(Day.Evening);
    AllOverThisLand(); // OK I took that one a bit too far.
}
{% endhighlight %}

Very often, extracting methods will leave you with a helpful suggestion
from our friend resharper: "This method could be made static". I have
often noticed a reticence from fellow developers for following this
advice. Static methods tend to be considered harmful and seem to take us
back to the bad old days of global methods (not to mention global
state...). Added to that, the performance improvement you get is
negligible and might smell like unnecessary optimisation. What tends to happen is
that ReSharper is ignored (or the message is disabled) and we continue
with something else. Thisc course of action does rather miss the point:
the method makes no use of 'this'. So even if you don't put the static
keyword in front of it, the method is still basically static anyway.
Does that not tell you that maybe that method might not belong here? But
where should it go? This is where the 'do it anyway' part comes in. Go
make the method static. If there are several similar methods (and there
usually are), go make all of them static and then look for patterns:

-   A set of functions that take in a type you control:

{% highlight csharp %}
   public bool static HasExpiredPassword(User user) {...}
   public bool static HasPermissionToEditResource(User user, Resource resource) {...}
{% endhighlight %}

Perhaps this reasoning could be part of the User class as instance
methods.

-   Methods which take in a system type as the first parameter, all with
 the same/similar name, for example:
{% highlight csharp %}
public static  bool IsValidEmailAddress(string emailAddress){...}
public static string GetEmailHostName(string emailAddress )
{% endhighlight %}

Maybe email address warrants a class of it's own containing these
methods. The EmailAddress class could end up being a magnet for many
other similar methods dotted around other classes too.

-   Either of the above but taking in a collection/IEnumerable of the
    same, e.g. :
{% highlight csharp %}
static MailAddressCollection BuildSenderList(IEnumerable emailAddresses)
static IEnumerable GetAllUsersInGroup(IEnumerable users, Group group)
{% endhighlight %}

    Here, extension methods are your friend for a quick fix (ReSharper
    can totally help you out here). Chances are that if 'User' is part
    of your domain model, then 'Users' should be too. So why not create
    a type representing the collection - Users, EmailAddresses - and
    migrate the static methods there.

Simply by following our refactoring tool's suggestion, we have made the
code more expressive and readable. The design of our code has fallen
into place without us having to think too hard (a very good thing).

So what if you can't find a way to move around those static methods? I
would suggest that you should still go static to acknowledge that the
methods are slightly disjunct from the class. Maybe as your codebase
grows, you can revisit and find a place for these new concepts.
