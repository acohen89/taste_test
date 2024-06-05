
from django.urls import path
from . import views

urlpatterns = [
    path('create_recipe', views.create_recipe),
    path('test', views.test),
    path('get_user_recipes', views.get_user_recipes),
    path('get_recipe/', views.get_recipe),
    path('get_recipe_iterations/', views.get_recipe_iterations),
    path('delete_recipe', views.delete_recipe),
    path('delete_all_user_recipes', views.delete_all_user_recipes)
]