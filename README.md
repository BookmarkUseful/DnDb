# DnDb (work in progress)

This is a Rails-based RESTful API to quickly fetch rules for 5th-edition [Dungeons and Dragons](http://dnd.wizards.com/).

This is used by myself in conjunction with its [front-end component](https://github.com/gdrandal/dnd-frontend).

Along with POST, PUT, and DELETE, it features the following GET endpoints to reference rules:

* `/api/spells`
* `/api/spells/:id`
* `/api/character_classes`
* `/api/character_classes/:id`
* `/api/subclasses`
* `/api/subclasses/:id`
* `/api/feats`
* `/api/feats/:id`
* `/api/skills`
* `/api/skills/:id`
* `/api/sources`
* `/api/sources/:id`

Other resources, like races, items, and monsters are not yet implemented. Each existing endpoint can be filtered according to relevant parameters. For instances, the `/api/spells` endpoint can be filtered by `schools`, `sources` (source ids), `classes` (character class ids), and `kinds` (`core`, `supplement`, `unearthed_arcana`, or `homebrew`).

A response might look something like this (some fields have been omitted):

**Sample Request**

`GET /api/spells?schools[]=conjuration&schools[]=transmutation&kinds[]=supplement`

**Sample Response**

```
[
	{
		"name": "Bones of the Earth",
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
			"kind": "supplement"
		},
		...
	},
	{
		"name": "Create Bonfire",
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

Note: No data is included in this repository. The API and the data that populates it is used privately. This is not meant for distribution. It is a personal project.
