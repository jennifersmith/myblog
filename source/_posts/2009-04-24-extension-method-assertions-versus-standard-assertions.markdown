---
author: admin
slug: extension-method-assertions-versus-standard-assertions
status: publish
title: Extension method assertions versus standard assertions
categories:
- Software Development
tags:
- testing
- assertions

---

I have been playing around lately with assertions in my tests and
figuring out the best (funnest?) way to work with them. Within the
context of BDD style testing there seems to have emerged a style for
using extension methods for asserts. As I found out at the
[SkillsMatter](http://www.skillsmatter.com "SkillsMatter")
[NBehave](http://nbehave.org/ "NBehave bdd framework") talk, NBehave
comes with a set of extension method wrapped assertion methods so I
guess that is where the link comes from perhaps.

### What do I mean by extension method assertions?

OK so a normal vanilla unit test might
check that the conditions of the test are met as follows:

{% highlight c# %}
      Assert.IsEqual(foo, bar);
      Assert.IsNotNull(foobar123);
{% endhighlight %}

Or if you have been bitten by the fluent bug:

{% highlight c# %}
      Assert.That(foo, Is.EqualTo(bar));
      Assert.That(foobar123, Is.NotNull());
{% endhighlight %}

Anyway, if you use the extension methods approach you will typically
have defined somewhere something like:
{% highlight c# %}
public static class AssertionExtensions
{
        public static T ShouldBe<T>(this object val)
        {
            Assert.That(val, Is.InstanceOf(typeof (T)));
            return (T) val;
        }

        public static void ShouldBeNull(this Object val)
        {
            Assert.That(val, Is.Null);
        }
}
{% endhighlight %}

Leaving your asserts looking something like:
{% highlight c# %}
   foo.ShouldEqual(bar);
   foobar123.IsNotNull();
{% endhighlight %}

You could even read that back and it might make some sort of sense: "Foo
shoud equal bar". "Foobar123 should not be null". As far as C\# goes,
that is pretty damn readable (I see you Ruby-heads smirking at the
back!).

###Taking it a bit further
 I have started to get into BDD style
testing for project number one (well, the parts that aint smart-ui
anyway), and I have got slightly carried away with my extension method
asserts. As each test is testing a different outcome of the behaviour
under test, I think the best tests only have one line of code in them.
Something like:
{% highlight c# %}
[TestFixture]
public When_user_sends_article_to_a_friend 
{
       ....
       [Test]
       public void Email_is_sent_to_the_friends_address_via_email_service()
       {
               EmailService
                    .EmailWasSent()
                    .To("Fred@flintstone.com");
       }
}

{% endhighlight %}

(For the record my assertions have never got to more than one method,
but it would be possible right!). Arguably you could just say this is a
bit of syntactic sugar, but I think it hides the complexity of what it
means to satisfy these requirements... which I believe is A Good Thing.
At first glance, I should be able to read this code out loud and have
half a chance at figuring out the intentions of what was supposed to be
tested. I don't need to worry whether EmailService is a
stub/mock/stubbed-mock(!) - and indeed if it starts life as a mock then
progresses to a concrete, this test doesn't need to change. 

###It's not for BAs
One argument I have heard for extension-method assertions is
that it 'makes it readable for business analysts'. Now, if your business
analyst happens to be a former programmer, you might be on to something.
However, that is not usually the case, our BAs can't understand it and
such a claim rather detracts from the usefulness of these methods.
Really what we should be thinking about is the how readable extension
method assertions are for us! If someone asks me 'what does this
function do' and I wrote it about 10 days ago (this is about the maximum
time I can remember anything about something I have created), I can find
out easily and quickly. Similarly, the poor dev who comes after me could
probably have a go at comprehending it too.
