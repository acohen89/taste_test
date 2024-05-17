from rest_framework import serializers
from .models import Recipe, UserRecipes

class RecipeSerializer(serializers.ModelSerializer):
    class Meta(object):
        model = Recipe 
        fields = '__all__'

class UserRecipesSerializer(serializers.ModelSerializer):
    class Meta(object):
        model = UserRecipes
        fields = '__all__'