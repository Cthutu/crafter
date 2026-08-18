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
underscores, dashes and asterisks). An asterisk can be used as a prefix for
group symbols, such as `*wood`.

An example recipe file is:

```
# This is a comment
# Each recipe is defined by a line with the following format:
# item_name[quantity]: ingredient1[quantity] ingredient2[quantity] ... ingredientN[quantity]
#
# Quantity (in brackets) is optional and defaults to 1 if not specified.
# A reusable ingredient is written as item_name[+] or item_name[+quantity].
#
# If an item can be crafted from other items, those items should also be
# defined in the recipe file.
#

plank[4]: log
crafting-table: plank[4] 
```

Then, when the user runs the command `crafter my-recipes.txt crafting-table`,
the output will be:

```
Ingredients:
    log: 1

Stage 1:
    plank: 4

Stage 2:
    crafting-table: 1
```

An optional stack size can be supplied before the recipes file:
`crafter --stack 64 my-recipes.txt crafting-table`. Quantities greater than the
stack size are displayed as the number of full stacks and the leftover count;
for example, 100 is displayed as `1/36` with a stack size of 64.

Multiple recipes can be requested in one command. They are combined into a
single crafting plan, including any ingredients they share:
`crafter my-recipes.txt crafting-table plank`.

Reusable ingredients, such as tools, are marked with `[+]`. They are required
only once for the entire crafting plan rather than once per crafting batch. A
specific global quantity can be requested with `[+n]`; for example,
`hammer[+3]` requires three hammers regardless of how many recipes use them.
When the same reusable item appears more than once, the largest requested
reusable quantity is used.

# Implementation

It will be implemented in the `Nerd` programming language, whose repository is
found at `~/nerd`.
