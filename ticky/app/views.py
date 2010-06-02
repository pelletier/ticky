from django.core.cache import cache
from django.http import HttpResponse
from django.shortcuts import redirect
from django.shortcuts import render_to_response as render
from django.template import RequestContext
from ticky.app.models import Version


def download_latest(request):
    """Redirect to the latest version download"""
    data = Version.objects.order_by('-pubdate')[0]
    return redirect(data.download_link)
    
    
def versions_index(request, template_name="app/versions.html"):
    """Display the list of versions and additional stuff"""
    data = {
        'versions': Version.objects.order_by('-pubdate'),
    }
    return render(template_name, data, context_instance=RequestContext(request))
    