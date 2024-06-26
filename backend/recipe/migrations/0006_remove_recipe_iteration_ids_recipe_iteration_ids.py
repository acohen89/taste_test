# Generated by Django 4.2.11 on 2024-04-26 21:47

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("recipe", "0005_alter_recipe_iteration_ids"),
    ]

    operations = [
        migrations.RemoveField(model_name="recipe", name="iteration_ids",),
        migrations.AddField(
            model_name="recipe",
            name="iteration_ids",
            field=models.ManyToManyField(
                default=None, related_name="iterations", to="recipe.recipe"
            ),
        ),
    ]
