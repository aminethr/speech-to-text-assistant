"""
URL configuration for SpeechAssistant project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from speechassistantapp import views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('Singup/', views.create_user_view, name='Singup'),
    path('Login/', views.login_view, name='Login'),
    path('Model Answer/', views.nlp_answer, name='Model Answer'),
    path('Summary Answer/', views.summary_answer, name='Summary Answer'),
    path('Requests History/', views.get_history, name='Requests History'),
    path('Change Password/', views.change_password, name='Requests History'),

]
