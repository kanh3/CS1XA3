from django.http import HttpResponse, JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
import json

from .models import UserInfo1


def register_user(request):
    """recieves a json request { 'username' : 'val0', 'password' : 'val1' } and saves it
       it to the database using the django User Model
       Assumes success and returns an empty Http Response"""

    json_req = json.loads(request.body)
    uname = json_req.get('username','')
    passw = json_req.get('password','')

    if uname != '':
        try: # try if there is a player with same username
            user = User.objects.create_user(username=uname,
                                        password=passw)
            login(request,user)
            response='LoggedIn'
            try:
                UserInfo1.objects.create_user_info(user)
            except:
                pass
        except:# if there is then ask the player to choose another username
            response='UserExists'
        return HttpResponse(response)

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
    """is the restpage between loginpage and gamepage. shows high record if LoggedIn
    gives login message but does not force user to go to loginpage"""
    d = {}
    if not request.user.is_authenticated:
        d['username'] = ""
        d['day'] = 0
        d['value'] = 0
        d['error'] = "please log in first. Click on Logout to go to loginpage."

    else:
        # getuserinfo if logged in
        d['username'] = request.user.username
        user = User.objects.get(username=request.user.username)
        getuserinfo = UserInfo1.objects.get(user1=user)
        d['day'] = getuserinfo.hd
        d['value'] = getuserinfo.hv
        d['error'] = ""
    return JsonResponse(d)

def resume_game(request):
    """changes the resume game status to True if user wants to resume game"""
    if not request.user.is_authenticated:
        return HttpResponse('Loggedout')
    else:
        user = User.objects.get(username=request.user.username)
        getuserinfo = UserInfo1.objects.get(user1=user)
        getuserinfo.resume=True
        getuserinfo.save()
        return HttpResponse('ResumeGame')

def new_game(request):
    """changes the new game status to True if user wants to start new game"""
    if not request.user.is_authenticated:
        return HttpResponse('Loggedout')
    else:
        user = User.objects.get(username=request.user.username)
        getuserinfo = UserInfo1.objects.get(user1=user)
        getuserinfo.new=True
        getuserinfo.save()
        return HttpResponse('NewGame')

def quit_game(request):
    """saves the game progress and record, stores info in database in case the user wants to resume game"""
    json_req = json.loads(request.body)
    money = json_req.get('money','')
    day= json_req.get('day','')
    price1= json_req.get('price','')[0]
    price2= json_req.get('price','')[1]
    q1 = json_req.get('q1','')
    q2 = json_req.get('q2','')
    if not request.user.is_authenticated:
        return HttpResponse('LoggedOut')

    else:
        try:
            user = User.objects.get(username=request.user.username)
            UserInfo1.objects.change_user_info(user,money,day,price1,price2,q1,q2)#change info
            return HttpResponse('Success')
        except:

            return HttpResponse('SaveFailed')

def get_status(request):
    """gets game status new/resume/both?/neither?, returns HttpResponse accordingsly"""
    if not request.user.is_authenticated:
        return HttpResponse('Loggedout')
    else:
        user = User.objects.get(username=request.user.username)
        getuserinfo = UserInfo1.objects.get(user1=user)
        if getuserinfo.new == True:
            getuserinfo.new = False #need to be reset to False
            getuserinfo.save()
            if getuserinfo.resume == False:
                return HttpResponse('NewGame')
            else:
                getuserinfo.resume = False #need to be reset to False
                getuserinfo.save()
                return HttpResponse('Both')
        else:
            if getuserinfo.resume == False:
                return HttpResponse('None')
            else:
                getuserinfo.resume=False #need to be reset to False
                getuserinfo.save()
                return HttpResponse('ResumeGame')


def get_data(request):
    """gets info from database because user chooses to resume game. returns a new model which restores progress"""
    d = {}
    if not request.user.is_authenticated: #same as new game
        d['money'] = 100
        d['day'] = 1
        d['price'] = [10,30]
        d['q1'] = 0
        d['q2'] = 0
        d['bas1'] = 0
        d['bas2'] = 0
        d['text'] = ""

    else:
        user = User.objects.get(username=request.user.username)
        getuserinfo = UserInfo1.objects.get(user1=user)
        basket = getuserinfo.basket#get info from basket
        banana=basket.get(name='banana')
        banana.save()
        pineapple=basket.get(name='pineapple')
        pineapple.save()
        d['money'] = getuserinfo.money
        d['day'] = getuserinfo.day
        d['price'] = [banana.price,pineapple.price]
        d['q1'] = banana.quantity
        d['q2'] = pineapple.quantity
        d['bas1'] = 0# these didn't got saved!!
        d['bas2'] = 0# just initialize is fine
        d['text'] = ""
    return JsonResponse(d)

