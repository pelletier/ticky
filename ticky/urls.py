from django.conf.urls.defaults import *
from django.conf import settings
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'ticky.misc.views.index', name="home"),
    url(r'^license/$', 'ticky.misc.views.license', name="license"),
    url(r'^download/$', 'ticky.app.views.download_latest', name="download_latest"),
    url(r'^versions/$', 'ticky.app.views.versions_index', name="versions"),
    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),
)

# Debug URLs
if settings.DEBUG:
    urlpatterns += patterns('',
    (r'^site_media/(?P<path>.*)$', 'django.views.static.serve',
            {'document_root': settings.MEDIA_ROOT}),
    (r'^404/', 'django.views.generic.simple.direct_to_template',
            {'template': '404.html'}),
    (r'^500/', 'django.views.generic.simple.direct_to_template',
            {'template': '500.html'}),
    )
    