# DnDb (work in progress)

This is a Rails-based RESTful API to quickly fetch rules for 5th-edition [Dungeons and Dragons](http://dnd.wizards.com/).

This is used by myself in conjunction with its [front-end component](https://github.com/gdrandal/dnd-frontend), with plans to release a free public API of the [5e SRD](http://dnd.wizards.com/articles/features/systems-reference-document-srd).

It features the following GET endpoints to reference rules:

* `/api/backgrounds`
* `/api/backgrounds/(:id|:slug)`
* `/api/character_classes`
* `/api/character_classes/(:id|:slug)`
* `/api/feats`
* `/api/feats/(:id|:slug)`
* `/api/races`
* `/api/races/(:id|:slug)`
* `/api/subraces`
* `/api/subraces/(:id|:slug)`
* `/api/skills`
* `/api/skills/(:id|:slug)`
* `/api/sources`
* `/api/sources/(:id|:slug)`
* `/api/spells`
* `/api/spells/(:id|:slug)`
* `/api/subclasses`
* `/api/subclasses/(:id|:slug)`

Other resources, like items and monsters, are not yet implemented. Each existing endpoint can be filtered according to relevant parameters. For instance, the `/api/spells` endpoint can be filtered by `schools`, `sources` (source ids or slugs), `classes` (character class ids or slugs), and `kinds` (`core`, `supplement`, `unearthed_arcana`, or `homebrew`).

A response might look something like this (some fields have been omitted):

**Sample Request**

`GET /api/spells?schools[]=conjuration&schools[]=transmutation&kinds[]=supplement`

**Sample Response**

```
[
	{
		"name": "Bones of the Earth",
		"slug": "bones-of-the-earth",
		"level": 6,
		"school": "transmutation",
		"description": "You cause up to six pillars of stone to burst from places on the ground...",
		"character_classes": [
			{
				"name": "Druid",
				"id": 4
			}
		],
		"source": {
			"name": "Xanathar's Guide to Everything",
			"kind": "supplement",
			"id": 14
		},
		...
	},
	{
		"name": "Catapult",
		"slug": "catapult",
		"level": 1,
		"school": "transmutation",
		"description": "Choose one object weighing 1 to 5 pounds within range...",
		"character_classes": [
			{
				"name": "Sorcerer",
				"id": 10
			},
			{
				"name": "Wizard",
				"id": 12
			}
		],
		"source": {
			"name": "Xanathar's Guide to Everything",
			"kind": "supplement",
			"id": 14
		},
		...
	},
	{
		"name": "Create Bonfire",
		"slug": "create-bonfire",
		"level": 0,
		"school": "conjuration",
		"description": "You create a bonfire on ground that you can see within range. Until the spell ends...",
		"character_classes": [
			{
				"name": "Druid",
				"id": 4
			},
			{
				"name": "Sorcerer",
				"id": 10
			},
			{
				"name": "Warlock",
				"id": 11
			},
			{
				"name": "Wizard",
				"id": 12
			}
		],
		"source": {
			"id": 14,
			"name": "Xanathar's Guide to Everything",
			"kind": "supplement"
		},
		...
	},
	...
]
```

Other requests might include:

`GET /api/spells?schools[]=conjuration&schools[]=transmutation&classes[]=bard`

`GET /api/spells?schools[]=conjuration&schools[]=transmutation&classes[]=4`

`GET /api/feats?prerequisite=true&sources[]=xanathars-guide-to-everything`

`GET /api/subclasses?kinds[]=homebrew&classes[]=fighter`

Note: No data is included in this repository. The API and the data that populates it is used privately. This is not meant for distribution. It is a personal project.
