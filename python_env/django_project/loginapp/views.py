from django.shortcuts import render
from django.http import HttpResponse
# Create your views here.
def post_view(request):
    name = request.POST.get("name", "")
    password = request.POST.get("password", "")
    if name == "Jimmy" and password == "Hendrix":
        return HttpResponse("Cool")
    return HttpResponse("Bad Username")
