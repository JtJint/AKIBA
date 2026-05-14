# Board API: List Posts By Hashtag

Swagger source: `https://api.dev.akiba-shop.com/swagger-ui/index.html#/board-controller/listPostsByHashtag`

OpenAPI operation: `listPostsByHashtag`

## Endpoint

```http
GET /api/boards/hashtags/{hashtag}/posts
```

Base URL:

```text
https://api.dev.akiba-shop.com
```

## Description

Returns community board posts that include the requested hashtag.

## Path Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `hashtag` | `string` | Yes | Hashtag used to filter board posts. |

## Request Example

```http
GET https://api.dev.akiba-shop.com/api/boards/hashtags/haikyu/posts
```

## Response

### `200 OK`

Returns an array of `PostSummaryResponse`.

```json
[
  {
    "postId": 1,
    "boardCode": "FREE",
    "userId": 10,
    "author": "nickname",
    "title": "post title",
    "content": "post content",
    "createdAt": "2026-05-14T04:31:53.000Z",
    "likeCount": 0,
    "commentCount": 0,
    "imageUrls": [
      "https://example.com/image.jpg"
    ],
    "hashtags": [
      "haikyu"
    ],
    "saleOrAuctionLink": "https://example.com/item",
    "authenticVoteCount": 0,
    "fakeVoteCount": 0
  }
]
```

## `PostSummaryResponse`

| Field | Type | Description |
| --- | --- | --- |
| `postId` | `integer(int64)` | Post ID. |
| `boardCode` | `string` | Board code. One of `FREE`, `AUTHENTICITY`, `QNA_HELP`. |
| `userId` | `integer(int64)` | Author user ID. |
| `author` | `string` | Author nickname/name. |
| `title` | `string` | Post title. |
| `content` | `string` | Post content summary/body. |
| `createdAt` | `string(date-time)` | Creation time. |
| `likeCount` | `integer(int32)` | Like count. |
| `commentCount` | `integer(int32)` | Comment count. |
| `imageUrls` | `string[]` | Attached image URLs. |
| `hashtags` | `string[]` | Hashtags attached to the post. |
| `saleOrAuctionLink` | `string` | Linked sale or auction URL. |
| `authenticVoteCount` | `integer(int32)` | Authentic vote count. |
| `fakeVoteCount` | `integer(int32)` | Fake vote count. |

## Notes

- Swagger marks global security as bearer auth, but this specific operation does not declare an `Authorization` header parameter.
- If the backend applies global auth at runtime, call this endpoint through `AuthHttpClient.get(...)` so the access token is attached automatically.
