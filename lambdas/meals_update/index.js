/**
 * PUT /meals/update - Update an existing meal
 */
const { UpdateCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEALS_TABLE = process.env.MEALS_TABLE_NAME;

const ALLOWED_FIELDS = ['name', 'description', 'ingredients', 'tags', 'imageUrl'];

exports.handler = async (event) => {
  try {
    const userId = getUserId(event);
    const body = JSON.parse(event.body || '{}');
    const { mealId } = body;
    if (!mealId) return error('mealId is required');

    // Build update expression from allowed fields
    const updates = [];
    const names = {};
    const values = {};

    for (const field of ALLOWED_FIELDS) {
      if (body[field] !== undefined) {
        updates.push(`#${field} = :${field}`);
        names[`#${field}`] = field;
        values[`:${field}`] = body[field];
      }
    }

    if (updates.length === 0) return error('No fields to update');

    updates.push('#updatedAt = :updatedAt');
    names['#updatedAt'] = 'updatedAt';
    values[':updatedAt'] = new Date().toISOString();

    const result = await dynamo.send(new UpdateCommand({
      TableName: MEALS_TABLE,
      Key: { userId, mealId },
      UpdateExpression: `SET ${updates.join(', ')}`,
      ExpressionAttributeNames: names,
      ExpressionAttributeValues: values,
      ConditionExpression: 'attribute_exists(userId)',
      ReturnValues: 'ALL_NEW',
    }));

    return success({ meal: result.Attributes });
  } catch (err) {
    console.error('meals_update error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    if (err.name === 'ConditionalCheckFailedException') return error('Meal not found', 404);
    return error('Failed to update meal', 500);
  }
};
