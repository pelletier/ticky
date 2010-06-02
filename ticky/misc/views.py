from datetime import datetime
from django.shortcuts import render_to_response as render
from django.template import RequestContext
from django.core.cache import cache
from django.conf import settings
import twitter


def index(request, template_name="misc/index.html"):
    data = {}
    tweets = cache.get( 'tweets' )

    if not tweets:
        tweets = twitter.Api().GetUserTimeline( settings.TWITTER_USER )[:5]
        for tweet in tweets:
            tweet.date = datetime.strptime( tweet.created_at, "%a %b %d %H:%M:%S +0000 %Y" )
    
        cache.set( 'tweets', tweets, settings.TWITTER_TIMEOUT )
    
    data['tweets'] = tweets
    
    return render(template_name, data, context_instance=RequestContext(request))
    
def license(request, template_name="misc/license.html"):
    data = {}
    return render(template_name, data, context_instance=RequestContext(request))