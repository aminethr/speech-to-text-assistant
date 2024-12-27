from django.shortcuts import render
from django.contrib.auth import authenticate, login , update_session_auth_hash
from rest_framework.decorators import api_view, permission_classes
from .models import SpeechData , NlpData , create_user_with_token , User
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.authtoken.models import Token
import speech_recognition as sr
from rest_framework import status
from openai import OpenAI

import os


client = OpenAI(
    # defaults to os.environ.get("OPENAI_API_KEY")
    api_key="OPEN AI API KEY",
)



@api_view(['POST'])
def create_user_view(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')

    success, user, token = create_user_with_token(username, email, password)
    

    if success==True:
        return Response({'message': 'User created successfully.', 'token': token.key}, status=status.HTTP_201_CREATED)
    else:
        return Response({'message': token}, status=status.HTTP_400_BAD_REQUEST)
    


@api_view(['POST'])
def login_view(request):
    username = request.data.get('username')
    password = request.data.get('password')


    user = authenticate( username=username, password=password)
    print(user)
    if user :
        login(request, user)
        token = Token.objects.get(user=user)
        return Response({'message': 'Login successful.', 'token': token.key}, status=status.HTTP_200_OK)
    else:
        return Response({'message': 'Wrong username or password.'}, status=status.HTTP_401_UNAUTHORIZED)
    


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def nlp_answer(request):
    aud_text=request.data['speech_txt']

    if not aud_text:
        return Response({'error': 'No audio data found'}, status=status.HTTP_400_BAD_REQUEST)

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": aud_text}]
    )


    answer = response.choices[0].message.content.strip()

    user = request.user

    speechdata=SpeechData.objects.create(user=user,text_transcript=aud_text)
    speechdata.save()

    answerdata=NlpData.objects.create(speechdata=speechdata,user_query=aud_text,model_response=answer)
    answerdata.save()

    
    return Response({'text': answer}, status=status.HTTP_200_OK)





@api_view(['POST'])
@permission_classes([IsAuthenticated])
def summary_answer(request):
    aud_text=request.data['speech_txt']
    aud_text= "give me the summary of this text: "+aud_text
    if not aud_text:
        return Response({'error': 'No audio data found'}, status=status.HTTP_400_BAD_REQUEST)

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": aud_text}]
    )


    answer = response.choices[0].message.content.strip()

    user = request.user

    speechdata=SpeechData.objects.create(user=user,text_transcript=aud_text)
    speechdata.save()

    answerdata=NlpData.objects.create(speechdata=speechdata,user_query=aud_text,model_response=answer)
    answerdata.save()

    
    return Response({'text': answer}, status=status.HTTP_200_OK)





@api_view(['GET', 'DELETE'])
@permission_classes([IsAuthenticated])
def get_history(request):
 
 if request.method == 'GET':
    user = request.user
    history_req=NlpData.objects.filter(speechdata__user=user).values_list('user_query', flat=True)
    history_ans=NlpData.objects.filter(speechdata__user=user).values_list('model_response', flat=True)
    
    return Response({'history_req': history_req , 'history_ans': history_ans }, status=status.HTTP_200_OK)
 
 elif request.method == 'DELETE':
        # Assuming the ID of the history entry to be deleted is passed as a query parameter
        history_id = request.query_params.get('id')
        if not history_id:
            return Response({'error': 'Missing history ID'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            history_entry = NlpData.objects.get(id=history_id, speechdata__user=request.user)  # Ensure the entry belongs to the user
            history_entry.delete()
            return Response({'message': 'The Selected requests deleted successfully'}, status=status.HTTP_204_NO_CONTENT)
        except NlpData.DoesNotExist:
            return Response({'error': 'History entry not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    user = request.user
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')

    if not request.user.check_password(old_password):
        return Response({'error': 'Old password is incorrect'}, status=status.HTTP_400_BAD_REQUEST)
    

    user.set_password(new_password)
    user.save()

    # Update session to prevent logging out the user after changing the password
    update_session_auth_hash(request, user)

    return Response({'success': 'Password changed successfully'}, status=status.HTTP_200_OK)
