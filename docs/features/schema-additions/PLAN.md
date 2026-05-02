# F2 Infra — Schema Additions: new lambdas + meal-comments table

**Status:** Ready (awaiting `terraform apply` approval)
**Owner:** Dominick
**Companion repos:** Xomware/meals-backend#8, Xomware/meals-frontend#6
**Parent epic:** `meals-backend/docs/features/xom-appetite-rollout/PLAN.md`

## Goal

Provision the AWS resources for the new schema features Dominick called for: ordered cooking instructions, structured ingredients, per-meal comments. Backend lambda code and frontend types/API client are already merged-pending in their respective PRs; this plan covers the AWS provisioning that must happen for those endpoints to actually work.

## What needs to change in `terraform/`

### 1. New DynamoDB table — `meal-comments`

Add to `dynamodb.tf` after the `meal_ratings` block:

```hcl
########################################
# 3. meal-comments
# PK: mealId (group all comments for a meal)
# SK: commentId (uuid)
########################################
resource "aws_dynamodb_table" "meal_comments" {
  name           = "${var.app_name}-meal-comments"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0
  hash_key       = "mealId"
  range_key      = "commentId"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_alias.dynamodb.target_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "mealId"
    type = "S"
  }

  attribute {
    name = "commentId"
    type = "S"
  }

  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-meal-comments" }))
}
```

### 2. Add 4 new lambdas to `lambdas_meals.tf`

Append to the `meals_lambdas` local list:

```hcl
{
  name        = "edit"
  description = "Update fields on an existing meal (instructions, ingredients, etc.)"
  path_part   = "edit"
  http_method = "PATCH"
},
{
  name        = "comment-add"
  description = "Add a comment to a meal"
  path_part   = "comment-add"
  http_method = "POST"
},
{
  name        = "comments-list"
  description = "List comments for a meal"
  path_part   = "comments-list"
  http_method = "GET"
},
{
  name        = "comment-delete"
  description = "Delete a comment (author only)"
  path_part   = "comment-delete"
  http_method = "DELETE"
},
```

> **Verify with the upstream `api-gateway-service` module (v2.2.0):** `path_part` semantics in this repo's lambdas don't directly match the actual REST paths in the README (e.g. `path_part=list` but REST is `GET /meals`). Confirm what paths the new entries above produce before applying. The expected REST paths are:
>   - `PATCH /meals/{id}`
>   - `POST /meals/{id}/comments`
>   - `GET /meals/{id}/comments`
>   - `DELETE /meals/{id}/comments/{commentId}`
>
> If the module needs a different `path_part` shape (e.g. nested resources, path params), the local entries above need to change accordingly. **Do not apply until this is verified.**

### 3. Add `MEAL_COMMENTS_TABLE_NAME` to lambda env vars

In `locals.tf`, update `lambda_variables`:

```hcl
lambda_variables = {
  APP_NAME                  = var.app_name
  MEALS_TABLE_NAME          = aws_dynamodb_table.meals.id
  MEAL_RATINGS_TABLE_NAME   = aws_dynamodb_table.meal_ratings.id
  MEAL_COMMENTS_TABLE_NAME  = aws_dynamodb_table.meal_comments.id   # NEW
  AWS_ACCOUNT_ID            = data.aws_caller_identity.web_app_account.account_id
}
```

### 4. IAM — no change required

The existing `lambda_role_policy` grants DynamoDB access to `arn:...:table/${var.app_name}*` so the new `${var.app_name}-meal-comments` table is already covered. No IAM update.

## ⚠️ Pre-existing env-var-name mismatch (separate bug)

While drafting this plan, found that lambda code reads:
- `process.env.RATINGS_TABLE_NAME` (in `meals-rate`, `meals-ratings`)
- `process.env.MEALS_TABLE_NAME` (everywhere else — matches Terraform)

But `terraform/locals.tf` sets:
- `MEAL_RATINGS_TABLE_NAME` (note: differs from what the code reads)
- `MEALS_TABLE_NAME` (matches)

So **`meals-rate` and `meals-ratings` are likely broken in production** (table name resolves to `undefined`, all DynamoDB calls fail). Either:
1. The lambdas have never actually been exercised in prod (rating UI may not have been used), or
2. The env var is being set somewhere outside Terraform (didn't find it).

**Recommendation:** Fix in the same PR that adds the new env var. Two options:
- **A.** Update lambda code to read `MEAL_RATINGS_TABLE_NAME` (matches existing Terraform convention; the new comments var would follow as `MEAL_COMMENTS_TABLE_NAME`)
- **B.** Update Terraform to also export `RATINGS_TABLE_NAME` (matches existing lambda code; new comments var would be `COMMENTS_TABLE_NAME`)

The companion backend PR uses `COMMENTS_TABLE_NAME` (option B style). If you go with option A, both the backend PR and the existing rate/ratings lambdas should be updated for consistency. Pick one before applying.

## Apply checklist

- [ ] Verify `path_part` shape matches what `api-gateway-service` v2.2.0 expects for the new endpoints
- [ ] Decide A vs B for the env var naming inconsistency above
- [ ] If A: update `meals-backend` lambdas to use `MEAL_RATINGS_TABLE_NAME` and `MEAL_COMMENTS_TABLE_NAME`. If B: keep current lambda code, but add `RATINGS_TABLE_NAME` to Terraform (and use `COMMENTS_TABLE_NAME` here)
- [ ] `terraform plan` and review the diff (expected: 1 new table, 4 new lambdas, 4 new API Gateway routes/methods, lambda env-var update)
- [ ] `terraform apply`
- [ ] Manually verify new endpoints respond (curl with `X-Auth-Hash`)
- [ ] Re-deploy meals-backend lambdas (so the new lambdas pick up real handler code instead of the `lambda_stub.zip` Terraform provisions)

## Out of scope

- The rename to `xom-appetite-*` (separate plan: F3)
- The new subdomain provisioning for the frontend (separate plan: F4)
