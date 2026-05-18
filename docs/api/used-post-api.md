# Used Post API

Base URL:

```text
https://api.dev.akiba-shop.com
```

Swagger tag: `used-post-controller`

## Overview

중고거래 게시글 목록, 상세, 작성, 수정, 삭제, 인기글 조회에 사용하는 API입니다.

프론트 구현 시에는 `AuthHttpClient`를 통해 호출하는 것을 기본으로 합니다. 토큰이 필요한 API에서 `401`이 발생하면 access token 재발급 후 1회 재시도하는 공통 로직을 사용할 수 있습니다.

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/used/posts/{postId}` | 해당 `postId`의 상세 정보를 가져와 상세화면으로 이동할 때 사용 |
| `PUT` | `/api/used/posts/{postId}` | 글 수정 |
| `DELETE` | `/api/used/posts/{postId}` | 글 삭제 |
| `GET` | `/api/used/posts` | page 기반으로 글 요약 정보를 가져와 리스트업할 때 사용 |
| `POST` | `/api/used/posts` | 글 게시 |
| `GET` | `/api/used/posts/popular` | 인기 많은 글 조회 |

## GET `/api/used/posts/{postId}`

해당 `postId`의 중고거래 상세 정보를 조회합니다.

### Path Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `postId` | `integer(int64)` | Yes | 중고거래 게시글 ID |

### Response

`200 OK`

```json
{
  "postId": 1,
  "type": "USED",
  "title": "우즈마키 나루토 피규어",
  "content": "상세 설명",
  "price": 5000,
  "productCondition": "미개봉",
  "specialType": "NONE",
  "status": "판매중",
  "deliveryMethod": "택배",
  "purchaseSource": "구매처",
  "receiptMediaId": 10,
  "viewCount": 45,
  "favoriteCount": 5,
  "createdAt": "2026-05-14T04:31:53.000Z",
  "images": [
    {
      "mediaId": 1,
      "imageUrl": "https://example.com/image.jpg",
      "sortOrder": 0
    }
  ],
  "tags": ["나루토"],
  "seller": {
    "userId": 1,
    "nickname": "나루토짱",
    "profileImageUrl": "https://example.com/profile.jpg",
    "bio": "언제든 쪽지 환영입니다!",
    "dealCount": 4,
    "reviewCount": 3
  },
  "favorite": true
}
```

## PUT `/api/used/posts/{postId}`

중고거래 게시글을 수정합니다.

### Path Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `postId` | `integer(int64)` | Yes | 수정할 중고거래 게시글 ID |

### Request Body

Schema: `UsedPostUpdateRequest`

```json
{
  "title": "string",
  "content": "string",
  "price": 0,
  "productCondition": "개봉",
  "specialType": "NONE",
  "categoryId": 0,
  "deliveryMethod": "직거래",
  "purchaseSource": "string",
  "receiptMediaId": 0,
  "imageMediaIds": [0],
  "tagNames": ["string"]
}
```

### Response

`200 OK`

Swagger response schema: `Map<String, string>`

## DELETE `/api/used/posts/{postId}`

중고거래 게시글을 삭제합니다.

### Path Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `postId` | `integer(int64)` | Yes | 삭제할 중고거래 게시글 ID |

### Response

`200 OK`

Swagger response schema: `Map<String, string>`

## GET `/api/used/posts`

중고거래 게시글 목록을 조회합니다. 리스트 화면에서 page 기반으로 요약 정보를 가져올 때 사용합니다.

### Query Parameters

| Name | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `categoryId` | `integer(int64)` | No | - | 카테고리 ID 필터 |
| `status` | `string` | No | - | 판매 상태 필터 |
| `sort` | `string` | No | `latest` | 정렬 기준 |
| `page` | `integer(int32)` | No | `0` | 페이지 번호 |
| `size` | `integer(int32)` | No | `20` | 페이지 크기 |

### Response

`200 OK`

Swagger response schema: `object`

> 서버 응답이 page wrapper 형태일 수 있으므로 프론트에서는 `data`, `content`, `result`, `posts`, `items` 등을 유연하게 파싱하는 구조를 유지합니다.

## POST `/api/used/posts`

중고거래 게시글을 작성합니다.

### Request Body

Schema: `UsedPostCreateRequest`

```json
{
  "title": "string",
  "content": "string",
  "price": 0,
  "productCondition": "개봉",
  "specialType": "NONE",
  "categoryId": 0,
  "deliveryMethod": "직거래",
  "purchaseSource": "string",
  "receiptMediaId": 0,
  "imageMediaIds": [0],
  "tagNames": ["string"]
}
```

### Required Fields

| Field | Rule |
| --- | --- |
| `title` | Required, max length `200` |
| `content` | Required, min length `1` |
| `price` | Required, number, minimum `0` |
| `productCondition` | Required, must match `개봉` or `미개봉` |
| `deliveryMethod` | Required, must match `택배` or `직거래` |
| `imageMediaIds` | Required, `minItems: 1` |

### Optional Fields

| Field | Type | Note |
| --- | --- | --- |
| `specialType` | `string` | 현재 프론트에서는 `NONE` 고정 |
| `categoryId` | `integer(int64)` | 카테고리 ID |
| `purchaseSource` | `string` | 구매처 |
| `receiptMediaId` | `integer(int64)` | 영수증 이미지 media ID |
| `tagNames` | `string[]` | 최대 5개 |

### Upload Flow

이미지 파일을 바로 게시글 DTO에 넣지 않습니다.

1. 이미지 파일마다 `POST /api/media/upload` 호출
2. 응답에서 `mediaId` 수집
3. 게시글 작성 시 `imageMediaIds`에 media ID 배열 전달

### Response

`200 OK`

Swagger response schema: `object`

## GET `/api/used/posts/popular`

인기 많은 중고거래 게시글을 조회합니다.

### Query Parameters

| Name | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `limit` | `integer(int32)` | No | `10` | 가져올 인기글 개수 |

### Response

`200 OK`

Swagger response schema: `object`

## DTO Reference

### `UsedPostCreateRequest` / `UsedPostUpdateRequest`

| Field | Type | Required | Validation |
| --- | --- | --- | --- |
| `title` | `string` | Yes | max length `200` |
| `content` | `string` | Yes | min length `1` |
| `price` | `number` | Yes | minimum `0` |
| `productCondition` | `string` | Yes | `개봉` or `미개봉` |
| `specialType` | `string` | No | 현재 `NONE` 사용 |
| `categoryId` | `integer(int64)` | No | - |
| `deliveryMethod` | `string` | Yes | `택배` or `직거래` |
| `purchaseSource` | `string` | No | - |
| `receiptMediaId` | `integer(int64)` | No | - |
| `imageMediaIds` | `integer(int64)[]` | Yes | min items `1` |
| `tagNames` | `string[]` | No | max items `5` |

### `UsedPostDetailResponse`

| Field | Type |
| --- | --- |
| `postId` | `integer(int64)` |
| `type` | `string` |
| `title` | `string` |
| `content` | `string` |
| `price` | `number` |
| `productCondition` | `string` |
| `specialType` | `string` |
| `status` | `string` |
| `deliveryMethod` | `string` |
| `purchaseSource` | `string` |
| `receiptMediaId` | `integer(int64)` |
| `viewCount` | `integer(int32)` |
| `favoriteCount` | `integer(int32)` |
| `createdAt` | `string(date-time)` |
| `images` | `ImageResponse[]` |
| `tags` | `string[]` |
| `seller` | `SellerResponse` |
| `favorite` | `boolean` |

### `ImageResponse`

| Field | Type |
| --- | --- |
| `mediaId` | `integer(int64)` |
| `imageUrl` | `string` |
| `sortOrder` | `integer(int32)` |

### `SellerResponse`

| Field | Type |
| --- | --- |
| `userId` | `integer(int64)` |
| `nickname` | `string` |
| `profileImageUrl` | `string` |
| `bio` | `string` |
| `dealCount` | `integer(int32)` |
| `reviewCount` | `integer(int32)` |

## Current Frontend Mapping

| Frontend File | Responsibility |
| --- | --- |
| `lib/used/api/used_trade_api.dart` | 목록/detail GET |
| `lib/market/api/market_post_api.dart` | 중고거래 POST |
| `lib/wirte/write_page.dart` | 작성 화면, 이미지 업로드 후 DTO 생성 |
| `lib/media/api/media_api.dart` | 이미지 압축 및 `api/media/upload` |

## Implementation Notes

- `imageMediaIds`는 서버 스키마상 최소 1개가 필요합니다. 이미지 없이 작성하면 검증 실패 가능성이 큽니다.
- `price`는 Swagger상 `number`지만 현재 Flutter 코드에서는 `int`로 보내고 있습니다. 정수 가격만 허용한다면 문제 없습니다.
- `specialType`은 현재 기획에 따라 `NONE`으로 고정합니다.
- 작성/수정/삭제는 인증이 필요할 수 있으므로 `AuthHttpClient` 사용을 기본으로 합니다.
