from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.response import Response
from django.core import serializers
from rest_framework import status
from django.http import HttpResponse, JsonResponse
from .models import Recipe, UserRecipes
from recipe.serializers import RecipeSerializer, UserRecipesSerializer
from rest_framework.permissions import IsAuthenticated

# Create your views here.
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def create_recipe(request):
    recipeSerializer = RecipeSerializer(data=request.data)
    if recipeSerializer.is_valid(): 
        recipeSerializer.save()  
        if request.data["beginningRecipe"]:
            if UserRecipes.objects.filter(pk=request.user.pk).exists():
                ur = UserRecipes.objects.get(pk=request.user.pk)
                recipe = Recipe.objects.get(pk=recipeSerializer.data["id"])
                ur.recipesId.add(recipe)
                # recipeQuery = UserRecipes.objects.get(pk=request.user.pk).recipesId.all()
                # res = [{"id": recipe.id, "title": recipe.title} for recipe in recipeQuery]
                return Response(recipeSerializer.data, status=status.HTTP_202_ACCEPTED)
            else:
                URSData = {"userId": request.user.pk, "recipesId": [recipeSerializer.data["id"]]}
                URSerializer = UserRecipesSerializer(data=URSData)
                if URSerializer.is_valid():
                    URSerializer.save()
                    return Response(URSerializer.data, status=status.HTTP_201_CREATED) 
                else: 
                    return Response(URSerializer.errors, status=status.HTTP_400_BAD_REQUEST) 
        else:
            mainRecipe = Recipe.objects.get(pk=request.data["parentRID"])
            mainRecipe.iteration_ids.add(recipeSerializer.data["id"])
            return Response(recipeSerializer.data, status=status.HTTP_400_BAD_REQUEST) 
    else:
        return Response(recipeSerializer.errors, status=status.HTTP_400_BAD_REQUEST) 
    

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def get_user_recipes(request):
    recipes = [RecipeSerializer(r).data for r in UserRecipes.objects.get(pk=request.user.pk).recipesId.all()]
    # res = list(UserRecipes.objects.get(pk=request.user.pk).recipesId.all())
    return Response(recipes, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def get_recipe(request):
    if not Recipe.objects.filter(pk=request.data['id']).exists(): 
        return Response({"message": "Recipe ID not found"}, status=status.HTTP_404_NOT_FOUND) 
    recipe = Recipe.objects.get(pk=request.data['id'])
    mainRecipe = RecipeSerializer(recipe)
    iterations = [RecipeSerializer(r).data for r in recipe.iteration_ids.all()]
    ret = {"mainRecipe": mainRecipe.data, "iterations": iterations}
    return Response(ret, status=status.HTTP_202_ACCEPTED)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def get_recipe(request):
    if not Recipe.objects.filter(pk=request.data['id']).exists(): 
        return Response({"message": f"Recipe ID: {request.data['id']} not found"}, status=status.HTTP_404_NOT_FOUND) 
    recipe = Recipe.objects.get(pk=request.data['id'])
    mainRecipe = RecipeSerializer(recipe)
    iterations = [RecipeSerializer(r).data for r in recipe.iteration_ids.all()]
    ret = {"mainRecipe": mainRecipe.data, "iterations": iterations}
    return Response(ret, status=status.HTTP_202_ACCEPTED)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def delete_recipe(request):
    if not Recipe.objects.filter(pk=request.data['id']).exists(): 
        return Response({"message": f"recipe with ID: {request.data['id']} not found"}, status=status.HTTP_404_NOT_FOUND)
    r = Recipe.objects.filter(pk=request.data['id'])
    r.delete()
    return Response({"message": f"Deleted recipe with id {request.data['id']}"}, status=status.HTTP_202_ACCEPTED)



@api_view(['POST'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def test(request):

    return Response({}, status=status.HTTP_202_ACCEPTED)


