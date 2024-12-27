from django.contrib import admin
from speechassistantapp.models import SpeechData , NlpData
# Register your models here.


admin.site.register(SpeechData)
admin.site.register( NlpData)