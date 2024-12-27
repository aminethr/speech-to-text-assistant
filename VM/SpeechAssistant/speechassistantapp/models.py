from django.db import models
from django.contrib.auth.models import User
from django.contrib.auth import hashers
from rest_framework.authtoken.models import Token
from django.db.models import Q


from django.db import IntegrityError  # Import IntegrityError for database constraints
from datetime import datetime, timedelta

def create_user_with_token(username, email, password):
    try:
        existing_user = User.objects.filter(Q(username=username) | Q(email=email)).exists()
        
        if existing_user:
            return False, None, "User already exists."
        
        new_user = User.objects.create_user(username=username, email=email, password=password)
        
        token, created = Token.objects.get_or_create(user=new_user)

        
        return True, new_user, token
    except IntegrityError as e:
        # Handle database integrity errors
        return False, None, "Database error: " + str(e)
    except Exception as e:
        # Catch other unexpected exceptions
        return False, None, "Unexpected error: " + str(e)


class SpeechData(models.Model):
    user=models.ForeignKey(User, on_delete = models.CASCADE)
    recording_date = models.DateTimeField(auto_now_add=True)
    text_transcript = models.TextField()

    def __str__(self):
      return self.user.username



class NlpData(models.Model):
    speechdata=models.ForeignKey(SpeechData, on_delete = models.CASCADE)
    user_query=models.TextField()
    model_response =models.TextField()
    created_at=models.DateTimeField(auto_now_add=True)


    def __str__(self):
      
      return self.speechdata.user.username