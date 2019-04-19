from django.shortcuts import render
from django.http import HttpResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
import json

from .models import UserInfo, Fruit

def register_user(request):
    """recieves a json request { 'username' : 'val0', 'password' : 'val1' } and saves it
       it to the database using the django User Model
       Assumes success and returns an empty Http Response"""

    json_req = json.loads(request.body)
    uname = json_req.get('username','')
    passw = json_req.get('password','')

    if uname != '':
	try:
        	user = User.objects.create_user(username=uname,
                                        password=passw)

        	login(request,user)
        	return HttpResponse('LoggedIn')
	except:
		return HttpResponse('UserExists')

    else:
        return HttpResponse('LoggedOut')


def login_user(request):
    """recieves a json request { 'username' : 'val0' : 'password' : 'val1' } and
       authenticates and loggs in the user upon success """

    json_req = json.loads(request.body)
    uname = json_req.get('username','')
    passw = json_req.get('password','')

    user = authenticate(request,username=uname,password=passw)
    if user is not None:
        login(request,user)
        return HttpResponse("LoggedIn")
    else:
        return HttpResponse('LoginFailed')

def user_info(request):
    """serves content that is only available to a logged in user"""

    if not request.user.is_authenticated:
        return HttpResponse("LoggedOut")
    else:
        # do something only a logged in user can do
        return HttpResponse("Hello " + request.user.username)
