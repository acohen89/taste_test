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
            print("here")
            curRecipe = Recipe.objects.get(pk=recipeSerializer.data["id"])
            mainRecipe = Recipe.objects.get(pk=request.data["parentRID"])
            mainRecipe.iteration_ids.add(curRecipe)
            return Response(recipeSerializer.data, status=status.HTTP_201_CREATED) 
    else:
        return Response(recipeSerializer.errors, status=status.HTTP_400_BAD_REQUEST) 
    

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def get_user_recipes(request):
    recipes = [RecipeSerializer(r).data for r in UserRecipes.objects.get(pk=request.user.pk).recipesId.all().order_by("-last_edited")]
    return Response(recipes, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def get_recipe(request):
    id = request.GET.get('id', '')
    if id == '': return Response({"Message":"No id parameter given"}, status=status.HTTP_406_NOT_ACCEPTABLE)
    if not Recipe.objects.filter(pk=id).exists(): 
        return Response({"message": "Recipe ID not found"}, status=status.HTTP_404_NOT_FOUND) 
    recipe = Recipe.objects.get(pk=id)
    mainRecipe = RecipeSerializer(recipe)
    iterations = [RecipeSerializer(r).data for r in recipe.iteration_ids.all()]
    ret = {"mainRecipe": mainRecipe.data, "iterations": iterations}
    return Response(ret, status=status.HTTP_202_ACCEPTED)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def get_recipe_iterations(request):
    id = request.GET.get('id', '')
    if id == '': return Response({"Message":"No id parameter given"}, status=status.HTTP_406_NOT_ACCEPTABLE)
    if not Recipe.objects.filter(pk=id).exists(): 
        return Response({"message": "Recipe ID not found"}, status=status.HTTP_404_NOT_FOUND) 
    recipe = Recipe.objects.get(pk=id)
    if not recipe.iteration_ids.exists() or not recipe.beginningRecipe:
        return Response({"Message":f"Iteration ids does not exist or beginningRecipe is {recipe.beginningRecipe}"},status=status.HTTP_404_NOT_FOUND)
    iterations = [RecipeSerializer(r).data for r in recipe.iteration_ids.all()]
    return Response({"iterations": iterations}, status=status.HTTP_202_ACCEPTED)

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


