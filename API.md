# API JSON Response Formats

## Notes

* This is just a work-in-progress and is not finalized by any means. *-BZ*

## User/Author

```json
{
    "username": "OtherUser",
    "following": false,
    "profile": {
        "avatar": "https://example.com/happy.png",
        "joinDate": "2020-09-20T12:22:53.867Z",
        "bio": "Just here to help debug!"
    }
}
```

### Notes

* In the event that this is returned as a ***field on a post***, the object will be labeled as
  `author`; otherwise, it will typically be `user`.
* The `following` field will be **missing** from an author in the event that the returned user is
  *you*, or you are *not logged in*. It is up to the client to determine which of those two states
  the user is in.
* The `avatar` and `bio` fields can be **null** in the `profile` object in the event that the
  user has not set them.

## Logged-in User

```json
{
    "authToken": "EXAMPLE_TOKEN",
    "username": "ExampleUser",
    "profile": {
        "avatar": null,
        "joinDate": "2020-09-25T15:12:35.126Z",
        "bio": null
    }
}
```

### Notes

* The returned user is *always* you, and therefore the `following` field is **never present**.
* `profile` can still have **null** `avatar` and `bio` fields if they have not been set.

## Post

```json
{
    "slug": "my-first-post-3fd63",
    "author": {
        "username": "SomeAuthor",
        "following": false,
        "profile": {
            "avatar": null,
            "joinDate": "2020-05-20T12:20:20.500Z",
            "bio": null
        }
    },
    "title": "My First Post!",
    "description": "This is my very first post on VS!",
    "tags": [
        "introduction"
    ],
    "createdAt": "2020-09-25T16:23:01.277Z",
    "editedAt": "2020-09-26T12:05:28.843Z",
    "starred": true,
    "starCount": 3,
    "commentCount": 0,
    "body": "This is an example post made of markdown."
}
```

### Notes

* The `description` field can be **null** in the event that the post does not have a description.
* The `editedAt` field can be **null** in the event that the post has never been edited.
* The `body` field can be **missing** in the event that the `post` was received from an API endpoint which returns ***lists of posts***; likewise, it will **exist** in the event that the `post` was received from an API endpoint for which returns ***a specific post***.

## Lists of Users

```json
{
    "users": [
        {
            "username": "DebugUser",
            "profile": {
                "avatar": null,
                "joinDate": "2020-09-25T15:12:35.126Z",
                "bio": null
            }
        },
        {
            "username": "OtherUser",
            "following": false,
            "profile": {
                "avatar": "https://example.com/happy.png",
                "joinDate": "2020-09-20T12:22:53.867Z",
                "bio": "Just here to help debug!"
            }
        }
    ]
}
```

## Lists of Posts

*Same general format as [lists of users](#lists-of-users).

## Errors

```json
{
    "errors": {
        "unauthorized": [
            "Client did not provide an authentication token."
        ]
    }
}
```

### Notes

* This particular error would also return a `401 Unauthorized` status
