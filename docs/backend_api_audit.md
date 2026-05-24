# AKIBA Backend API Audit

Backend source: https://github.com/jaykwon0207/AKIBA-Backend  
Inspected commit: `c69891685e0af492c087dc71175f35c0f858ed08` (`main`)

## Notes

- Base URL used by the frontend: `https://api.dev.akiba-shop.com/`
- Backend controllers are under `/api`.
- Current backend security config permits all requests globally, but many mutation endpoints still require a resolved `@AuthenticationPrincipal Long userId` and return 401 when it is missing.
- Auth header format expected by the frontend client: `Authorization: Bearer <accessToken>`.

## Frontend Coverage Summary

| Domain | Backend endpoints | Frontend status | Notes |
| --- | ---: | --- | --- |
| Users/Auth | 8 | Partial | login, me, refresh used. nickname/update/logout/delete/check-nickname mostly not wired. |
| Media | 2 | Partial | upload used. file retrieval URL is consumed indirectly only if image URLs come from backend. |
| Used posts | 6 | Mostly applied | create/list/detail/update/delete/popular all present. |
| Limited posts | 10 | Partial | list/popular used. create/detail/update/delete/status/search/similar/categories not fully wired. |
| Wanted posts | 5 | Mostly applied | create/list/detail/update/delete present. |
| Auction posts | 15 | Very partial | create present. listing/detail/bids/my/ending-soon/popular not wired; existing auction carousel is still dummy. |
| Market integrated | 10 | Not applied | search/categories/tags/recent/similar/popular/status available but not wired. |
| Boards/community | 15 | Not applied | community page is currently static UI; Board API not wired yet. |
| Chat | 0 in inspected backend | Frontend-only/mismatch | frontend calls `/api/chat/...`, but no chat controller found in backend repo. |
| Profile | 0 in inspected backend | Mismatch | frontend calls `/api/profile/me`, but backend exposes `/api/users/me`. |

## API Specification

### Users/Auth

| Method | Path | Request | Response | FE status |
| --- | --- | --- | --- | --- |
| POST | `/api/users/login` | `{provider, code, state}` | `{accessToken, refreshToken, userId, nickname, isNewUser}` | Used in `lib/Login/api/userApi.dart` |
| PATCH | `/api/users/nickname` | `{nickname}` | `{userId, nickname}` | Not wired |
| POST | `/api/users/logout` | none | `{message}` | FE only clears local storage; backend not called |
| GET | `/api/users/check-nickname?nickname=` | query | `{available, message}` | Not wired |
| DELETE | `/api/users` | auth principal | `{message}` | Not wired |
| GET | `/api/users/me` | auth principal | `{userId, email, nickname, provider, status, createdAt, bio, profileImageMediaId}` | Used in login API helper |
| PUT | `/api/users/me` | `{nickname, bio, profileImageMediaId}` | `{userId, nickname, bio, profileImageMediaId, message}` | Not wired |
| POST | `/api/users/refresh` | `{refreshToken}` | `{accessToken}` | Used in `AuthHttpClient` |

### Media

| Method | Path | Request | Response | FE status |
| --- | --- | --- | --- | --- |
| POST | `/api/media/upload` | multipart form-data, part name `file` | `{mediaId, ...}` | Used in `lib/media/api/media_api.dart` |
| GET | `/api/media/files/{mediaId}` | path | file resource | Not directly wrapped |

### Used Posts

| Method | Path | Request/Query | Response | FE status |
| --- | --- | --- | --- | --- |
| POST | `/api/used/posts` | `UsedPostCreateRequest` | `{postId, message}` | Used |
| GET | `/api/used/posts` | `categoryId?`, `status?`, `sort=latest`, `page=0`, `size=20` | `{posts/content/items..., pagination...}` | Used |
| GET | `/api/used/posts/{postId}` | path | `UsedPostDetailResponse` | Used |
| PUT | `/api/used/posts/{postId}` | `UsedPostUpdateRequest` | `{message}` | Used |
| DELETE | `/api/used/posts/{postId}` | path | `{message}` | Used |
| GET | `/api/used/posts/popular?limit=10` | query | `{posts}` | Used on home and used page |

`UsedPostCreateRequest` / `UsedPostUpdateRequest` fields:

```json
{
  "title": "string",
  "content": "string",
  "price": 10000,
  "productCondition": "개봉|미개봉",
  "specialType": "NONE|SPECIAL_BENEFIT|LIMITED_EDITION|BOTH",
  "categoryId": 1,
  "deliveryMethod": "택배|직거래",
  "purchaseSource": "string",
  "receiptMediaId": 1,
  "imageMediaIds": [1],
  "tagNames": ["tag"]
}
```

### Limited Posts

| Method | Path | Request/Query | Response | FE status |
| --- | --- | --- | --- | --- |
| POST | `/api/limited/posts` | `MarketPostCreateRequest` with `type: LIMITED` | `{postId, message}` | Not wired |
| GET | `/api/limited/posts` | `categoryId?`, `status?`, `sort=latest`, `page=0`, `size=20` | list map | Used |
| GET | `/api/limited/posts/{postId}` | path | `MarketPostDetailResponse` | Not wired |
| PUT | `/api/limited/posts/{postId}` | `MarketPostUpdateRequest` | `{message}` | Not wired |
| DELETE | `/api/limited/posts/{postId}` | path | `{message}` | Not wired |
| PATCH | `/api/limited/posts/{postId}/status` | `{status}` | `{message}` | Not wired |
| GET | `/api/limited/posts/popular?limit=10` | query | `{posts}` | Used on home |
| GET | `/api/limited/search?keyword=&sort=latest&page=0&size=20` | query | search result map | Not wired |
| GET | `/api/limited/posts/{postId}/similar?limit=10` | query | `{posts}` | Not wired |
| GET | `/api/limited/categories` | none | `{categories}` | Not wired |

`MarketPostCreateRequest` / `MarketPostUpdateRequest` is the same shape as used posts, plus required `type`.

### Wanted Posts

| Method | Path | Request/Query | Response | FE status |
| --- | --- | --- | --- | --- |
| POST | `/api/wanted/posts` | `WantedPostCreateRequest` | `{postId, message}` | Used |
| GET | `/api/wanted/posts` | `sort=latest`, `page=0`, `size=20` | list map | Used |
| GET | `/api/wanted/posts/{postId}` | path | `WantedPostDetailResponse` | Used |
| PUT | `/api/wanted/posts/{postId}` | `WantedPostUpdateRequest` | `{message}` | Used |
| DELETE | `/api/wanted/posts/{postId}` | path | `{message}` | Used |

`WantedPostCreateRequest` / `WantedPostUpdateRequest` fields:

```json
{
  "title": "string",
  "content": "string",
  "price": 10000,
  "specialType": "NONE|SPECIAL_BENEFIT|LIMITED_EDITION|BOTH",
  "conditionTxt": "개봉|미개봉",
  "deliveryMethod": "택배|직거래",
  "imageMediaIds": [1],
  "tagNames": ["tag"]
}
```

### Auction Posts

| Method | Path | Request/Query | Response | FE status |
| --- | --- | --- | --- | --- |
| POST | `/api/auction/posts` | `AuctionPostCreateRequest` | `{postId, message}` | Used for write flow |
| GET | `/api/auction/posts` | `status?`, `sort=latest`, `page=0`, `size=20` | list map | Used on auction screen |
| GET | `/api/auction/posts/{postId}` | path | `AuctionPostDetailResponse` | Not wired |
| PUT | `/api/auction/posts/{postId}` | `AuctionPostUpdateRequest` | `{message}` | Not wired |
| DELETE | `/api/auction/posts/{postId}` | path | `{message}` | Not wired |
| POST | `/api/auction/posts/{postId}/bids` | `{bidAmount}` | `BidResponse` | Not wired |
| POST | `/api/auction/posts/{postId}/bid` | `{bidAmount}` | `BidResponse` | Alias; not wired |
| POST | `/api/auction/posts/{postId}/buy-now` | none | `BidResponse` | Not wired |
| GET | `/api/auction/posts/{postId}/bids` | path | `BidHistoryListResponse` | Not wired |
| GET | `/api/auction/my/bids?page=0&size=20` | query | list map | Not wired |
| GET | `/api/auction/my/posts?page=0&size=20` | query | list map | Not wired |
| GET | `/api/auction/my/won?page=0&size=20` | query | list map | Not wired |
| GET | `/api/auction/posts/popular?limit=10` | query | `{posts}` | Not wired |
| GET | `/api/auction/posts/ending-soon?limit=10` | query | `{posts}` | Used on home auction carousel and auction screen |
| GET | `/api/auction/search/popular` | none | `PopularKeywordResponse` | Not wired |
| GET | `/api/auction/tags/recommended` | none | `{tags}` | Not wired |

`AuctionPostCreateRequest` / `AuctionPostUpdateRequest` fields:

```json
{
  "title": "string",
  "content": "string",
  "productCondition": "개봉|미개봉",
  "specialType": "NONE|SPECIAL_BENEFIT|LIMITED_EDITION|BOTH",
  "categoryId": 1,
  "startPrice": 10000,
  "buyNowPrice": 20000,
  "bidStep": 1000,
  "endsAt": "2026-05-24T12:00:00",
  "deliveryMethod": "택배|직거래",
  "purchaseSource": "string",
  "receiptMediaId": 1,
  "imageMediaIds": [1],
  "tagNames": ["tag"]
}
```

### Market Integrated

| Method | Path | Query/Request | FE status |
| --- | --- | --- | --- |
| GET | `/api/market/search` | `keyword`, `type?`, `onlyActive=true`, `unOpenedOnly=false`, `sort=latest`, `page=0`, `size=20` | Used on search result screen |
| GET | `/api/market/search/popular?limit=10` | query | Used on search screen |
| GET | `/api/market/tags/recommended?type=&limit=10` | query | Used on search screen |
| GET | `/api/market/categories` | none | Not wired |
| GET | `/api/market/posts/recent-views?limit=10` | auth principal | Not wired |
| GET | `/api/market/posts` | `type?`, `status?`, `keyword?`, `onlyActive`, `unOpenedOnly`, `sort`, `page`, `size` | Not wired |
| GET | `/api/market/posts/{postId}` | path | Not wired |
| GET | `/api/market/posts/{postId}/similar?limit=10` | query | Not wired |
| GET | `/api/market/posts/popular?type=USED&limit=10` | query | Not wired; FE uses type-specific `/used` and `/limited` popular endpoints |
| PATCH | `/api/market/posts/{postId}/status` | `{status}` | Not wired |

### Boards / Community

Board codes:

- `FREE`
- `AUTHENTICITY`
- `QNA_HELP`

| Method | Path | Request/Query | FE status |
| --- | --- | --- | --- |
| GET | `/api/boards` | none | Used on community home |
| GET | `/api/boards/{boardCode}/posts` | path | Used on community board list screen |
| GET | `/api/boards/popular/posts` | none | Used on community home and popular posts screen |
| GET | `/api/boards/search?keyword=` | query | Not wired |
| GET | `/api/boards/hashtags/{hashtag}/posts` | path | Not wired |
| POST | `/api/boards/{boardCode}/posts` | `CreatePostRequest` | Used on community write screen |
| GET | `/api/boards/{boardCode}/posts/{postId}` | path | Used on community post detail screen |
| PUT | `/api/boards/{boardCode}/posts/{postId}` | `UpdatePostRequest` | Not wired |
| DELETE | `/api/boards/{boardCode}/posts/{postId}?userId=` | query | Not wired |
| POST | `/api/boards/{boardCode}/posts/{postId}/comments` | `CreateCommentRequest` | Used on community detail screen |
| GET | `/api/boards/{boardCode}/posts/{postId}/comments` | path | Used on community detail screen |
| DELETE | `/api/boards/{boardCode}/comments/{commentId}?userId=` | query | Not wired |
| POST | `/api/boards/{boardCode}/posts/{postId}/like` | `{userId}` | Not wired |
| POST | `/api/boards/{boardCode}/comments/{commentId}/like` | `{userId}` | Not wired |
| POST | `/api/boards/{boardCode}/posts/{postId}/votes` | `{userId, choice}` | Not wired |

Board write request:

```json
{
  "userId": 1,
  "title": "string",
  "content": "string",
  "imageUrls": ["https://..."],
  "saleOrAuctionLink": "https://...",
  "hashtags": ["tag"]
}
```

Comment request:

```json
{
  "userId": 1,
  "parentId": null,
  "content": "string"
}
```

Vote request:

```json
{
  "userId": 1,
  "choice": "AUTHENTIC|FAKE"
}
```

## Mismatches / Action Items

1. Replace frontend profile endpoint.
   - Current FE: `GET /api/profile/me` in `lib/myPage/mypage.api.dart`
   - Backend: `GET /api/users/me`

2. Chat endpoints are missing in the inspected backend.
   - Current FE calls:
     - `GET /api/chat/rooms`
     - `POST /api/chat/rooms`
     - `GET /api/chat/rooms/{roomId}/messages`
     - `DELETE /api/chat/rooms/{roomId}`
   - No matching controller found in backend commit `c698916`.

3. Community page is mostly wired.
   - Wired:
     - `GET /api/boards`
     - `GET /api/boards/popular/posts`
     - `GET /api/boards/{boardCode}/posts`
     - `GET /api/boards/{boardCode}/posts/{postId}`
     - `POST /api/boards/{boardCode}/posts`
     - `GET /api/boards/{boardCode}/posts/{postId}/comments`
     - `POST /api/boards/{boardCode}/posts/{postId}/comments`
   - Still remaining:
     - update/delete, likes, comment likes, votes, hashtag/search list pages.

4. Search screen is wired to market search basics.
   - Wired:
     - `GET /api/market/search`
     - `GET /api/market/search/popular`
     - `GET /api/market/tags/recommended`

5. Auction UI is partially integrated.
   - Wired:
     - `GET /api/auction/posts`
     - `GET /api/auction/posts/ending-soon?limit=10`
   - Still remaining:
     - detail, bid, buy-now, bid history, my auction lists.

6. Login request includes extra `env` field on frontend.
   - Backend `LoginRequest` only declares `provider`, `code`, `state`.
   - If Jackson ignores unknown properties in runtime config, it is harmless; otherwise remove `env` or add it to backend DTO.

7. Limited detail route is absent on frontend.
   - Backend supports `GET /api/limited/posts/{postId}`, but the frontend currently routes limited cards back to list.
