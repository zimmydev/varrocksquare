# API JSON Response Formats

## Notes

* This is just a work-in-progress and is not finalized by any means. -BZ

## User

```json
{
	"user": {
		"username": "OtherUser",
		"following": true,
		"profile": {
			"avatar": "https://example.com/happy.png",
			"joinDate": "2020-09-25T15:12:35.126Z",
			"bio": "Just here to help debug!"
		}
	}
}
```

### Notes

* The `following` field will be missing in the event that the returned user is *you*.
* The `avatar` and `bio` fields can be *missing* from the `profile` object in the event that the user has not set them.

## Logged-in User

```json
{
	"loggedInUser": {
		"authToken": "AUTH_TOKEN_EXAMPLE",
		"user": {
			"username": "DebugUser",
			"profile": {
				"joinDate": "2020-09-25T15:12:35.126Z",
			}
		}
	}
}
```

### Notes

* The returned user is *always* you, and therefore the `following` field from the `user` object is always missing.
* `profile` can still be missing `avatar` and `bio` fields if they have not been set.

## Post

```json
{
    "post": {
        "slug": "my-first-post-3fd631",
        "author": {
	        // User…
	    }
        "title": "My First Post!",
	    "description": "This is my very first post on VS!"
        "tags": [
	        "introduction"
	    ],
	    "createdAt": "2020-09-25T16:23:01.277Z",
	    "updatedAt": null,
	    "starred": true,
	    "starCount": 3,
	    "commentCount": 0,
	    "body": "This is an example post made of markdown."
    }
}
```

### Notes

* The `body` field can be *missing* in the event that the `post` was received from an API endpoint which returns **lists of posts**; likewise, it will *exist* in the event that the `post` was received from an API endpoint for which returns **a specific post**.

## Lists of Posts

```json
{
	"posts": [
		{
			// Post…
		},
		{
			// Post…
		}
	]
}
```

## Lists of Users

```json
{
	"users": [
		{
			// User…
		},
		{
			// User…
		}
	]
}
```
