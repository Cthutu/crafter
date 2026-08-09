# Crafter

This command line application reads a recipes file and generates a list of
ingredients needed to craft the specified items. It is designed to help players
of crafting games manage their resources efficiently.

It supports items that take multiple ingredients to craft, as well as items that
can be crafted from other crafted items, and items that craft multiple items at
once.

The application will list the raw ingredients needed for crafting (those that
cannot be crafted from other items) followed by stages of crafting, showing the
intermediate items needed to craft the final products.

Each item is referenced by a unique name (which can have letters, numbers,
underscores and dashes).

An example recipe file is:

```
# This is a comment
# Each recipe is defined by a line with the following format:
# item_name[quantity]: ingredient1[quantity] ingredient2[quantity] ... ingredientN[quantity]
#
# Quantity (in braces) is optional and defaults to 1 if not specified.
#
# If an item can be crafted from other items, those items should also be
# defined in the recipe file.
#

plank[4]: log
crafting-table: plank[4] 
```

Then, when the user runs the command `crafter crafting-table`, the output will be:

```
Ingredients:
    log: 1

Stage 1:
    plank: 4

Stage 2:
    crafting-table: 1
```

# Implementation

It will be implemented in the `Nerd` programming language, whose repository is
found at `~/nerd`.



