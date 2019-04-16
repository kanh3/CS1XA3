from django.urls import path
from . import views
from django.http import HttpResponse

urlpatterns = [
    path('register/' , views.register_user , name= 'p3app-register_user'),
    path('login/', views.login_user, name="p3app-login_user"),
    path('userinfo/', views.user_info, name="p3app-user_info"),
]
