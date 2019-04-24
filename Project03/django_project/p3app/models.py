from django.db import models
from django.contrib.auth.models import User

class UserInfo1Manager(models.Manager):
    def create_user_info(self, user1): #initial setting
        userinfo = self.create(user1=user1)
        banana= Fruit.objects.create(name='banana')
        pineapple= Fruit.objects.create(name='pineapple')
        userinfo.basket.add(banana)
        userinfo.basket.add(pineapple)
        return userinfo
    def change_user_info(self,user1,money,d,p1,p2,q1,q2):#change userinfo
        userinfo = UserInfo1.objects.get(user1=user1)
        userinfo.money = money
        userinfo.day = d
        if d > userinfo.hd:#update highest day record
            userinfo.hd = d
        if money + p1*q1 + p2*q2 > userinfo.hv:#update highest value record
            userinfo.hv = money + p1*q1 + p2*q2
        #update basket
        banana=userinfo.basket.get(name='banana')
        banana.price=p1
        banana.quantity=q1
        banana.save()
        pineapple=userinfo.basket.get(name='pineapple')
        pineapple.price=p2
        pineapple.quantity=q2
        pineapple.save()
        userinfo.save()



class UserInfo1(models.Model):
    user1 = models.OneToOneField(User,
                                on_delete=models.CASCADE,
                                primary_key=True)#onetoone relation
    money = models.FloatField(default=100)
    day = models.IntegerField(default=1)
    hd = models.IntegerField(default=0)
    hv = models.FloatField(default=0)
    basket = models.ManyToManyField('Fruit',default=None)#using manytomany relation
    new = models.BooleanField(default=False)#new game?
    resume = models.BooleanField(default=False)#resume game?

    objects = UserInfo1Manager()

class Fruit(models.Model):
    name=models.CharField(max_length=30)
    price=models.FloatField(default=10)
    quantity=models.IntegerField(default=0)
