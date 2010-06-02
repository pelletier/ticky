from django import template
from ticky.app.models import Version

register = template.Library()


@register.simple_tag
def latest_version():
    data = Version.objects.order_by('-pubdate')[0]
    return data.number
