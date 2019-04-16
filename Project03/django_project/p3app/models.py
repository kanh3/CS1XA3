from django.db import models
from django.contrib.auth.models import User

class UserInfoManager(models.Manager):
    def create_user_info(self, username, password, info):
        user = User.objects.create_user(username=username,
                                        password=password)
        userinfo = self.create(user=user,money=money,basket=basket,info=info)

        return userinfo

class UserInfo(models.Model):
    user = models.OneToOneField(User,
                                on_delete=models.CASCADE,
                                primary_key=True)

    money = models.FloatField(default=100)
    basket = models.ManyToManyField('Fruit')
    info = models.CharField(max_length=30)

    objects = UserInfoManager()

class Fruit(models.Model):
    name=models.CharField(max_length=30)
    price=models.FloatField()
    quantity=models.IntegerField(default=0)
