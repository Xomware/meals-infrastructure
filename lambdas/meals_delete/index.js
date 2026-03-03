/**
 * DELETE /meals/delete - Delete a meal
 */
const { DeleteCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo } = require('../common/dynamo');
const { success, error } = require('../common/response');
const { getUserId } = require('../common/auth');

const MEALS_TABLE = process.env.MEALS_TABLE_NAME;

exports.handler = async (event) => {
  try {
    const userId = getUserId(event);
    const body = JSON.parse(event.body || '{}');
    const mealId = body.mealId || event.queryStringParameters?.mealId;
    if (!mealId) return error('mealId is required');

    await dynamo.send(new DeleteCommand({
      TableName: MEALS_TABLE,
      Key: { userId, mealId },
      ConditionExpression: 'attribute_exists(userId)',
    }));

    return success({ message: 'Meal deleted' });
  } catch (err) {
    console.error('meals_delete error:', err);
    if (err.message?.includes('Unauthorized')) return error(err.message, 401);
    if (err.name === 'ConditionalCheckFailedException') return error('Meal not found', 404);
    return error('Failed to delete meal', 500);
  }
};
