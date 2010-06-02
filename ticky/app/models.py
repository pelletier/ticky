from django.db import models
from django.contrib import admin

class Version(models.Model):
    number = models.CharField(max_length=10)
    release_notes = models.TextField(blank=True)
    is_beta = models.BooleanField(default=False)
    download_link = models.URLField(blank=True)
    checksum = models.CharField(blank=True, max_length=256)
    pubdate = models.DateTimeField(blank=True, null=True)
    size = models.IntegerField(blank=True, null=True)
    
    def __unicode__(self):
        return self.number
    
admin.site.register(Version)