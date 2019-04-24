from django.urls import path
from . import views


urlpatterns = [
    path('register/', views.register_user , name = 'p3app-register_user') ,
    path('login/', views.login_user , name = 'p3app-login_user') ,
    path('userinfo/', views.user_info , name = 'p3app-user_info') ,
    path('resume/', views.resume_game, name='p3app-resume_game'),
    path('new/', views.new_game, name='p3app-new_game'),
    path('quit/', views.quit_game, name='p3app-quit_game'),
    path('status/', views.get_status, name='p3app-get_status'),
    path('data/', views.get_data, name='p3app-get_data'),
]
