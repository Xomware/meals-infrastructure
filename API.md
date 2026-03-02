# Meals API Documentation

**Base URL:** `https://api.meals.xomware.com/dev`

All endpoints require a Bearer token in the `Authorization` header. The Lambda authorizer extracts `userId` from the JWT, which serves as the partition key for row-level security (RLS) — users can only access their own data.

---

## Authentication

```
Authorization: Bearer <jwt-token>
```

The JWT payload must contain `sub`, `userId`, or `email` to identify the user.

---

## Endpoints

### Meals CRUD

#### `GET /meals/list`
Get all meals for the authenticated user.

**Response:**
```json
{
  "meals": [
    {
      "userId": "user123",
      "mealId": "uuid",
      "name": "Chicken Parm",
      "description": "Classic Italian-American dish",
      "ingredients": ["chicken", "mozzarella", "marinara"],
      "tags": ["italian", "dinner"],
      "imageUrl": "https://...",
      "createdAt": "2026-03-02T12:00:00.000Z",
      "updatedAt": "2026-03-02T12:00:00.000Z"
    }
  ]
}
```

---

#### `POST /meals/create`
Create a new meal.

**Request Body:**
```json
{
  "name": "Chicken Parm",          // required
  "description": "...",             // optional
  "ingredients": ["chicken", ...],  // optional, array
  "tags": ["italian", "dinner"],    // optional, array
  "imageUrl": "https://..."         // optional
}
```

**Response (201):**
```json
{
  "meal": { ... }
}
```

---

#### `GET /meals/get?mealId=<uuid>`
Get a single meal by ID.

**Query Parameters:**
- `mealId` (required) — The meal UUID

**Response:**
```json
{
  "meal": { ... }
}
```

**Errors:** `404` if meal not found.

---

#### `PUT /meals/update`
Update an existing meal. Only provided fields are updated.

**Request Body:**
```json
{
  "mealId": "uuid",       // required
  "name": "New Name",     // optional
  "description": "...",   // optional
  "ingredients": [...],   // optional
  "tags": [...],          // optional
  "imageUrl": "..."       // optional
}
```

**Response:**
```json
{
  "meal": { ... }  // full updated meal
}
```

**Errors:** `404` if meal not found.

---

#### `DELETE /meals/delete`
Delete a meal.

**Request Body or Query Parameter:**
```json
{
  "mealId": "uuid"
}
```

**Response:**
```json
{
  "message": "Meal deleted"
}
```

---

### Ratings

#### `POST /meals/rate`
Create or update a rating for a meal. One rating per user per meal.

**Request Body:**
```json
{
  "mealId": "uuid",       // required
  "rating": 4,            // required, 1-5
  "comment": "Delicious!" // optional
}
```

**Response (201):**
```json
{
  "rating": {
    "userId": "user123",
    "mealId": "uuid",
    "rating": 4,
    "comment": "Delicious!",
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

#### `GET /meals/ratings?mealId=<uuid>`
Get all ratings for a meal (across all users).

**Query Parameters:**
- `mealId` (required)

**Response:**
```json
{
  "mealId": "uuid",
  "ratings": [ ... ],
  "averageRating": 4.2,
  "totalRatings": 5
}
```

---

## DynamoDB Schema

### `meals` table
| Key | Attribute | Type | Description |
|-----|-----------|------|-------------|
| PK  | `userId`  | S    | Partition key (RLS) |
| SK  | `mealId`  | S    | Sort key (UUID) |
|     | `name`    | S    | Meal name |
|     | `description` | S | Description |
|     | `ingredients` | L | List of strings |
|     | `tags`    | L    | List of strings |
|     | `imageUrl`| S    | Optional image URL |
|     | `createdAt` | S  | ISO 8601 timestamp |
|     | `updatedAt` | S  | ISO 8601 timestamp |

### `meal-ratings` table
| Key | Attribute | Type | Description |
|-----|-----------|------|-------------|
| PK  | `userId`  | S    | Partition key (RLS) |
| SK  | `mealId`  | S    | Sort key |
|     | `rating`  | N    | 1-5 rating |
|     | `comment` | S    | Optional comment |
|     | `createdAt` | S  | ISO 8601 timestamp |
|     | `updatedAt` | S  | ISO 8601 timestamp |

**GSI:** `mealId-userId-index` on `meal-ratings` — enables querying all ratings for a given meal.

## Row-Level Security (RLS)

Security is enforced at the application level via the partition key pattern:
1. The Lambda authorizer validates the JWT and extracts the `userId`
2. The `userId` is passed to downstream lambdas via the authorizer context
3. All DynamoDB queries use `userId` as the partition key
4. Users can only query/modify their own partition — there is no cross-user access path

## Deployment

1. Ensure `api_secret_key` variable is set in Terraform
2. `terraform init && terraform plan && terraform apply`
3. Deploy Lambda code via CI/CD (replace stub zips with actual bundles)
4. Each lambda directory maps to a function: `meals-meals-<name>`
