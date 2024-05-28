
from django.db import models
from django.contrib.postgres.fields import ArrayField
from django.contrib.auth.models import User

 
# Create your models here.
 
class UserRecipes(models.Model):
    userId = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True, related_name="userRecipes")
    recipesId = models.ManyToManyField("Recipe", default=None)
 
    def __str__(self):
        return str(self.recipesId)

    
class Recipe(models.Model):
    title = models.CharField(max_length=200)
    beginningRecipe = models.BooleanField(default=False)  # Make sure to add `default` argument
    parentRID = models.ForeignKey("self", null=True, on_delete=models.CASCADE, related_name="child_recipes")
    created = models.DateTimeField(auto_now_add=True)
    last_edited = models.DateTimeField(auto_now=True)  # Change `auto_now_add` to `auto_now`
    ingredients = ArrayField(models.CharField(max_length=75))
    image_url = models.URLField(null=True)
    procedure = ArrayField(models.CharField(max_length=75))
    notes = models.TextField(null=True)
    in_progress = models.BooleanField(default=False)  # Make sure to add `default` argument
    iteration_ids = models.ManyToManyField("Recipe", default=None, related_name="iterations")

    def __str__(self):
        return self.title
    