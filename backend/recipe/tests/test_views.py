

from django.test import TestCase, Client
from django.urls import reverse

from ..models import Recipe


class TestViews(TestCase):
    def setUp(self):
        self.client = Client()
        self.recipe = Recipe.objects.create(
        id= 1,
        title= "Pizza",
        beginningRecipe= False,
        created= "2024-04-26T21:48:36.387753Z",
        last_edited= "2024-04-26T21:48:36.387784Z",
        ingredients= [
            "200g flour",
            "1 can of sauce",
            "8oz cheese"
        ],
        image_url= "https=//example.com/spaghetti-bolognese.jpg",
        procedure= [
            "Step 1= Assemble",
            "Steph 2= cook"
        ],
        notes= "Garnish with fresh basil and grated Parmesan cheese.",
        in_progress= True,
        parentRID= None,
        )


    def test_unknown_recipe(self):
        body = {"id": self.recipe.id}
        response = self.client.get("get_recipe", body)
        self.assertEquals(response.status_code, 202)
